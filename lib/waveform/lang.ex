defmodule Waveform.Lang do
  use GenServer

  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  @me __MODULE__
  @path System.get_env("SCLANG_PATH") || "/Applications/SuperCollider.app/Contents/MacOS/sclang"

  defmodule State do
    defstruct(
      sclang_proc: nil,
      output_pid: nil
    )
  end

  def send_command(command) do
    GenServer.call(@me, {:command, command})
  end

  def start_server do
    GenServer.call(
      @me,
      {:command,
       """
         Server.local.options.sampleRate = 44100
         Server.internal.options.sampleRate = 44100
         Server.local.options.maxLogins = 2
         Server.internal.options.maxLogins = 2
         Server.default.boot
       """}
    )
  end

  # gen_server callbacks
  def start_link(_opts) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(_state) do
    sclang_proc =
      %Proc{out: outstream} =
      Porcelain.spawn(
        @path,
        [],
        in: :receive,
        out: :stream
      )

    output_pid =
      spawn(fn ->
        Enum.map(outstream, fn line ->
          # IO.puts(line)
          case line do
            "SuperCollider 3 server ready" <> _rest ->
              Waveform.OSC.load_synthdefs()
              Waveform.OSC.request_notifications()

            _ ->
              nil
          end

          line
        end)
      end)

    state = %State{
      sclang_proc: sclang_proc,
      output_pid: output_pid
    }

    {:ok, state}
  end

  def terminate(_reason, state) do
    Process.exit(state.output_pid, :kill)
  end

  def handle_call({:command, command}, _from, state) do
    Proc.send_input(state.sclang_proc, "#{command}\n")

    {:reply, nil, state}
  end
end
