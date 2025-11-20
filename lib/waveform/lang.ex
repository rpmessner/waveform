defmodule Waveform.Lang do
  @moduledoc """
  Manages the SuperCollider language (sclang) process.

  This module spawns and manages the `sclang` interpreter process, which in turn
  boots the SuperCollider audio server. It handles sending commands to sclang
  and monitors the process lifecycle.

  The sclang executable location can be configured via the `SCLANG_PATH` environment
  variable. If not set, it defaults to platform-specific installation paths.

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

  defmodule State do
    @moduledoc false
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

  defp get_sclang_path do
    System.get_env("SCLANG_PATH") || default_sclang_path()
  end

  defp default_sclang_path do
    case :os.type() do
      {:unix, :darwin} ->
        "/Applications/SuperCollider.app/Contents/MacOS/sclang"

      {:unix, _} ->
        # Linux: try common installation paths
        Enum.find(
          ["/usr/bin/sclang", "/usr/local/bin/sclang"],
          &File.exists?/1
        ) || "/usr/bin/sclang"

      {:win32, _} ->
        # Windows: try common installation paths
        Enum.find(
          [
            "C:\\Program Files\\SuperCollider\\sclang.exe",
            "C:\\Program Files (x86)\\SuperCollider\\sclang.exe"
          ],
          &File.exists?/1
        ) || "C:\\Program Files\\SuperCollider\\sclang.exe"
    end
  end

  def init(state) do
    sclang_path = get_sclang_path()

    # Skip SuperCollider check in CI environments
    unless System.get_env("CI") || File.exists?(sclang_path) do
      raise """
      SuperCollider not found at: #{sclang_path}

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

    # Skip starting sclang in CI environments
    if System.get_env("CI") do
      {:ok, %State{}}
    else
      start_sclang(state, sclang_path)
    end
  end

  defp start_sclang(_state, sclang_path) do
    case Exexec.run(
           sclang_path,
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
    if state.sclang_pid, do: Exexec.stop(state.sclang_pid)
  end

  def handle_call({:command, command}, _from, state) do
    if state.sclang_os_pid do
      Exexec.send(state.sclang_os_pid, "#{command}\n")
    end

    {:reply, nil, state}
  end
end
