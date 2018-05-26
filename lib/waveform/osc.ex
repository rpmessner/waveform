defmodule Waveform.OSC do
  use GenServer

  @me __MODULE__
  @synth_folder __ENV__.file
  |> Path.dirname
  |> Path.join("../../synthdefs/compiled")
  |> to_charlist

  defmodule State do
    defstruct(
      socket: nil,
      pid: nil,
      host: '127.0.0.1',
      host_port: 57110,
      udp_port: 57111
    )
  end

  def request_notifications do
    send_command(['/notify', 1])
  end

  def load_synthdefs do
    {:ok, cwd} = File.cwd
    send_command(['/d_loadDir', @synth_folder])
  end

  def send_command(command) do
    GenServer.cast(@me, {:command, command})
  end

  def start_link(_opts) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, socket} = :gen_udp.open(state.udp_port, [:binary, {:active, false}])

    Waveform.Lang.start_server

    pid = spawn fn -> udp_receive(socket) end

    state = %State{
      socket: socket,
      pid: pid
    }

    {:ok, state}
  end

  def terminate(_reason, state) do
    :gen_udp.close(state.socket)
    Process.exit(state.pid, :kill)
  end

  def handle_cast({:command, command}, state) do
    osc(state, command)
    {:noreply, state}
  end

  defp udp_receive(socket) do
    case :gen_udp.recv(socket, 0, 1000) do
      {:ok,{ip, port, the_message} = a} ->
        IO.inspect({"osc message:", :osc.decode(the_message)})
        udp_receive(socket)
      {:error, :timeout} -> udp_receive(socket)
    end
  end

  defp osc(state, command) do
    :ok = :gen_udp.send(state.socket, state.host, state.host_port, :osc.encode(command))
  end
end
