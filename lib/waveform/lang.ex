defmodule Waveform.Lang do
  use GenServer

  @me __MODULE__
  @path System.get_env("SCLANG_PATH") || "/Applications/SuperCollider.app/Contents/MacOS/sclang"

  defmodule State do
    defstruct(
      sclang_pid: nil,
      sclang_os_pid: nil
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
    {:ok, sclang_pid, sclang_os_pid} =
      Exexec.run(
        @path,
        [
          {:stdin, true},
          {:stdout,
           fn :stdout, _bytes, line ->
             # IO.puts(line)
             case line do
               "SuperCollider 3 server ready" <> _rest ->
                 Waveform.OSC.setup()

               _ ->
                 nil
             end
           end}
        ]
      )

    state = %State{
      sclang_pid: sclang_pid,
      sclang_os_pid: sclang_os_pid
    }

    {:ok, state}
  end

  def terminate(_reason, state) do
    Exexec.stop(state.sclang_pid)
  end

  def handle_call({:command, command}, _from, state) do
    Exexec.send(state.sclang_os_pid, "#{command}\n")

    {:reply, nil, state}
  end
end
