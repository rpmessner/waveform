defmodule Waveform.Lang do
  @moduledoc """
  Manages the SuperCollider language (sclang) process.

  This module spawns and manages the `sclang` interpreter process, which in turn
  boots the SuperCollider audio server. It handles sending commands to sclang
  and monitors the process lifecycle.

  The sclang executable location can be configured via the `SCLANG_PATH` environment
  variable. If not set, it defaults to the standard macOS installation path.

  ## Examples

      # Send arbitrary SuperCollider code
      Lang.send_command("s.boot;")

      # Define a synth
      Lang.send_command(\"\"\"
        SynthDef(\\\\simple, { |freq=440|
          Out.ar(0, SinOsc.ar(freq, 0, 0.1))
        }).add;
      \"\"\")
  """
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
    unless File.exists?(@path) do
      raise """
      SuperCollider not found at: #{@path}

      Waveform requires SuperCollider to be installed on your system.

      Installation instructions:

      macOS:
        brew install supercollider

      Linux (Debian/Ubuntu):
        sudo apt-get install supercollider

      Linux (Arch):
        sudo pacman -S supercollider

      Windows:
        Download from https://supercollider.github.io/

      If SuperCollider is installed in a non-standard location, set the SCLANG_PATH
      environment variable:

        export SCLANG_PATH=/path/to/sclang

      For more information, see: https://github.com/rpmessner/waveform#prerequisites
      """
    end

    case Exexec.run(
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
         ) do
      {:ok, sclang_pid, sclang_os_pid} ->
        state = %State{
          sclang_pid: sclang_pid,
          sclang_os_pid: sclang_os_pid
        }

        {:ok, state}

      {:error, reason} ->
        {:stop,
         "Failed to start SuperCollider (sclang): #{inspect(reason)}. " <>
           "Make sure SuperCollider is properly installed and sclang is executable."}
    end
  end

  def terminate(_reason, state) do
    Exexec.stop(state.sclang_pid)
  end

  def handle_call({:command, command}, _from, state) do
    Exexec.send(state.sclang_os_pid, "#{command}\n")

    {:reply, nil, state}
  end
end
