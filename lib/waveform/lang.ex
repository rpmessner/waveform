defmodule Waveform.Lang do
  use GenServer

  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  @me __MODULE__
  @path System.get_env("SCLANG_PATH") || "/Applications/SuperCollider.app/Contents/MacOS/sclang"

  defmodule State do
    defstruct(
      proc: nil,
      pid: nil,
      socket: nil
    )
  end

  def send_command(command) do
    GenServer.call(@me, {:sclang, command})
  end

  def start_server do
    GenServer.call(@me, {:command, """
      Server.local.options.sampleRate = 44100
      Server.internal.options.sampleRate = 44100
      Server.local.options.maxLogins = 2
      Server.internal.options.maxLogins = 2
      Server.default.boot
    """})
  end

  # gen_server callbacks
  def start_link(opts \\ []) do
    GenServer.start_link(@me, {}, name: @me)
  end

  def init(_state) do
    proc = %Proc{out: outstream} = Porcelain.spawn(
      @path, [], [in: :receive, out: :stream]
    )

    pid = spawn fn -> Enum.into(outstream, IO.stream(:stdio, :line)) end

    state = %State{
      proc: proc,
      pid: pid
    }

    {:ok, state}
  end

  def terminate(_reason, state) do
    Process.exit(state.pid, :kill)
  end

  def handle_call({:command, command}, _from, state) do
    Proc.send_input(state.proc, "#{command}\n")

    {:reply, nil, state}
  end
end
