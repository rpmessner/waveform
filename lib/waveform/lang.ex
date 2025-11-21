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
      sclang_os_pid: nil,
      server_ready: false,
      server_ready_subscribers: [],
      superdirt_ready: false,
      superdirt_ready_subscribers: []
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
         Server.local.options.numBuffers = 4096
         Server.internal.options.numBuffers = 4096
         Server.default.boot
       """}
    )
  end

  @doc """
  Wait for the SuperCollider server to be ready.

  Blocks until the server has booted and is ready to receive commands.
  Returns immediately if the server is already ready.

  ## Options

  - `:timeout` - Maximum time to wait in milliseconds (default: 30000)

  ## Examples

      Lang.wait_for_server()
      Lang.wait_for_server(timeout: 10000)
  """
  def wait_for_server(opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 30_000)
    GenServer.call(@me, :wait_for_server, timeout)
  end

  @doc """
  Wait for SuperDirt to be ready.

  Blocks until SuperDirt has been started and loaded all samples.
  Returns immediately if SuperDirt is already ready.

  ## Options

  - `:timeout` - Maximum time to wait in milliseconds (default: 60000)

  ## Examples

      Lang.wait_for_superdirt()
      Lang.wait_for_superdirt(timeout: 30000)
  """
  def wait_for_superdirt(opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 60_000)
    GenServer.call(@me, :wait_for_superdirt, timeout)
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
    case :exec.run(
           String.to_charlist(sclang_path),
           [:stdin, :stdout, :monitor]
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
    if state.sclang_os_pid, do: :exec.stop(state.sclang_os_pid)
  end

  def handle_call(:wait_for_server, _from, %State{server_ready: true} = state) do
    # Server already ready, reply immediately
    {:reply, :ok, state}
  end

  def handle_call(:wait_for_server, from, %State{server_ready: false} = state) do
    # Server not ready yet, add caller to subscribers list
    subscribers = [from | state.server_ready_subscribers]
    {:noreply, %{state | server_ready_subscribers: subscribers}}
  end

  def handle_call(:wait_for_superdirt, _from, %State{superdirt_ready: true} = state) do
    # SuperDirt already ready, reply immediately
    {:reply, :ok, state}
  end

  def handle_call(:wait_for_superdirt, from, %State{superdirt_ready: false} = state) do
    # SuperDirt not ready yet, add caller to subscribers list
    subscribers = [from | state.superdirt_ready_subscribers]
    {:noreply, %{state | superdirt_ready_subscribers: subscribers}}
  end

  def handle_call({:command, command}, _from, state) do
    if state.sclang_os_pid do
      :exec.send(state.sclang_os_pid, "#{command}\n")
    end

    {:reply, nil, state}
  end

  def handle_info({:stdout, _os_pid, data}, state) do
    # Process stdout from sclang
    line = IO.iodata_to_binary(data)
    # Uncomment for debugging: IO.puts("[SC] #{line}")

    cond do
      line =~ "SuperCollider 3 server ready" ->
        Waveform.OSC.setup()
        send(@me, :server_ready)
        {:noreply, state}

      # SuperDirt prints "SuperDirt: listening to Tidal on port 57120" when ready
      # This is more reliable than a custom postln since it's part of SuperDirt itself
      line =~ "SuperDirt: listening to Tidal on port" ->
        send(@me, :superdirt_ready)
        {:noreply, state}

      true ->
        {:noreply, state}
    end
  end

  def handle_info(:server_ready, state) do
    # Notify all waiting subscribers
    Enum.each(state.server_ready_subscribers, fn from ->
      GenServer.reply(from, :ok)
    end)

    {:noreply, %{state | server_ready: true, server_ready_subscribers: []}}
  end

  def handle_info(:superdirt_ready, state) do
    # Notify all waiting subscribers
    Enum.each(state.superdirt_ready_subscribers, fn from ->
      GenServer.reply(from, :ok)
    end)

    {:noreply, %{state | superdirt_ready: true, superdirt_ready_subscribers: []}}
  end
end
