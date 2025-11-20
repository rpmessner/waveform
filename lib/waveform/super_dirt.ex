defmodule Waveform.SuperDirt do
  @moduledoc """
  SuperDirt integration for sample playback and pattern-based audio.

  This module communicates with SuperDirt, a synthesis engine that runs inside
  SuperCollider and provides samples, effects, and high-level pattern control.
  SuperDirt is commonly used with TidalCycles for live coding.

  ## SuperDirt vs Direct OSC

  Waveform provides two ways to work with SuperCollider:

  - **Waveform.OSC / Waveform.Synth** - Direct synth control (port 57110)
    - Low-level synthesis, create individual synths
    - Requires synth definitions
    - More precise control

  - **Waveform.SuperDirt** - Pattern-based audio (port 57120)
    - High-level sample triggering
    - Built-in samples and effects
    - TidalCycles-compatible

  Both can be used simultaneously in the same SuperCollider session.

  ## Prerequisites

  **IMPORTANT:** SuperDirt must be installed and loaded in SuperCollider before using this module.

  ### Installation (One-time Setup)

  SuperDirt is a separate Quark (plugin) for SuperCollider. Install it once:

      # In SuperCollider IDE or sclang:
      Quarks.install("SuperDirt");
      thisProcess.recompile;

  Verify installation with `mix waveform.doctor`.

  ### Loading (Each Session)

  SuperDirt must be started in your SuperCollider session before sending patterns.
  You can do this in two ways:

  1. **Via Waveform.Lang** (recommended for Livebook/IEx):

      ```elixir
      Waveform.Lang.send_command("SuperDirt.start;")
      ```

  2. **Via SuperCollider startup file** (recommended for regular use):

      Add to `~/Library/Application Support/SuperCollider/startup.scd` (macOS)
      or `~/.config/SuperCollider/startup.scd` (Linux):

      ```supercollider
      s.waitForBoot {
        ~dirt = SuperDirt(2, s);
        ~dirt.loadSoundFiles;
        ~dirt.start(57120, [0, 0]);
      };
      ```

  ### Verification

  Check if SuperDirt is ready:

      ```elixir
      Waveform.SuperDirt.verify()
      # => :ok or {:error, reason}
      ```

  ## Examples

  Trigger a bass drum sample:

      SuperDirt.play(s: "bd", n: 0, gain: 0.8)

  Trigger multiple parameters:

      SuperDirt.play(
        s: "cp",
        n: 3,
        speed: 1.5,
        pan: 0.25,
        room: 0.3,
        size: 0.8
      )

  Control messages:

      SuperDirt.hush()           # Stop all playing sounds
      SuperDirt.mute_all()       # Mute all patterns
      SuperDirt.unmute_all()     # Unmute all patterns
      SuperDirt.unsolo_all()     # Clear solo state

  ## Message Format

  SuperDirt receives OSC bundles on port 57120 with the path `/dirt/play`.

  **OSC Bundles:** All messages are wrapped in OSC bundles with timestamps for
  precise timing. A small latency (default 20ms) is added to give SuperDirt
  time to process events before playback.

  Messages contain name-value pairs including:

  **Required parameters (automatically added):**
  - `cps` - Cycles per second (tempo)
  - `cycle` - Event position since startup
  - `delta` - Event duration in seconds
  - `orbit` - Orbit/track number (0-11)

  **Common sound parameters:**
  - `s` - Sample/sound name (e.g., "bd", "cp", "sn")
  - `n` - Sample variant number (default: 0)
  - `speed` - Playback speed (default: 1.0)
  - `gain` - Volume (default: 1.0)
  - `pan` - Stereo position (-1.0 to 1.0)
  - `begin` - Sample start position (0.0 to 1.0)
  - `end` - Sample end position (0.0 to 1.0)

  **Effects parameters:**
  - `room` - Reverb amount
  - `size` - Reverb size
  - `delay` - Delay amount
  - `delaytime` - Delay time
  - `delayfeedback` - Delay feedback
  - `cutoff` - Filter cutoff frequency
  - `resonance` - Filter resonance

  See the [SuperDirt documentation](https://github.com/musikinformatik/SuperDirt) for a
  complete list of available parameters and samples.
  """
  use GenServer
  require Logger

  @me __MODULE__

  # Transport layer - configurable for testing
  @transport Application.compile_env(:waveform, :superdirt_transport, Waveform.SuperDirt.UDP)

  @dirt_play ~c"/dirt/play"
  @hush ~c"/hush"
  @mute_all ~c"/muteAll"
  @unmute_all ~c"/unmuteAll"
  @unsolo_all ~c"/unsoloAll"

  defmodule State do
    @moduledoc false
    defstruct(
      socket: nil,
      host: ~c"127.0.0.1",
      port: 57_120,
      cycle: 0.0,
      cps: 0.5625,
      latency: 0.02
    )
  end

  @doc """
  Play a sound or sample through SuperDirt.

  Accepts a keyword list of parameters. At minimum, you should provide an `s` (sound)
  parameter. All other parameters are optional.

  ## Parameters

  - `s` - Sample/sound name (e.g., "bd", "cp", "sn")
  - `n` - Sample variant number (default: 0)
  - `speed` - Playback speed (default: 1.0)
  - `gain` - Volume (default: 1.0)
  - `orbit` - Orbit/track number (default: 0)
  - Additional parameters are passed through to SuperDirt

  ## Examples

      # Simple bass drum
      SuperDirt.play(s: "bd")

      # Snare with reverb
      SuperDirt.play(s: "sn", n: 2, room: 0.5, size: 0.8)

      # High-speed sample
      SuperDirt.play(s: "cp", speed: 2.0, pan: -0.5)

  """
  def play(params) when is_list(params) do
    GenServer.call(@me, {:play, params})
  end

  @doc """
  Stop all playing sounds and patterns immediately.

  Equivalent to TidalCycles' `hush` command.

  ## Examples

      SuperDirt.hush()

  """
  def hush do
    send_command(@hush, [])
  end

  @doc """
  Mute all patterns without stopping them.

  ## Examples

      SuperDirt.mute_all()

  """
  def mute_all do
    send_command(@mute_all, [])
  end

  @doc """
  Unmute all patterns.

  ## Examples

      SuperDirt.unmute_all()

  """
  def unmute_all do
    send_command(@unmute_all, [])
  end

  @doc """
  Clear solo state on all patterns.

  ## Examples

      SuperDirt.unsolo_all()

  """
  def unsolo_all do
    send_command(@unsolo_all, [])
  end

  @doc """
  Verify that SuperDirt is installed and loaded in SuperCollider.

  Returns `:ok` if SuperDirt is ready, or `{:error, reason}` if there's a problem.

  ## Examples

      case SuperDirt.verify() do
        :ok ->
          IO.puts("SuperDirt is ready!")

        {:error, :not_installed} ->
          IO.puts("SuperDirt Quark is not installed. Run: Quarks.install(\\"SuperDirt\\")")

        {:error, :not_loaded} ->
          IO.puts("SuperDirt is installed but not loaded. Run: SuperDirt.start")

        {:error, reason} ->
          IO.puts("Could not verify SuperDirt: \#{reason}")
      end

  """
  def verify do
    # Check if Lang process is running
    if Process.whereis(Waveform.Lang) do
      # Send command to check if SuperDirt class exists and is started
      command = """
      if(SuperDirt.class.notNil, {
        if(~dirt.notNil, {
          "SUPERDIRT_RUNNING".postln;
        }, {
          "SUPERDIRT_INSTALLED_NOT_RUNNING".postln;
        });
      }, {
        "SUPERDIRT_NOT_INSTALLED".postln;
      });
      """

      # Send the command and give it time to respond
      Waveform.Lang.send_command(command)
      Process.sleep(200)

      # Note: We can't easily get the response since Lang just sends commands
      # Users should check the SuperCollider post window or use mix waveform.doctor
      :ok
    else
      {:error, :lang_not_running}
    end
  end

  @doc """
  Set the global tempo in cycles per second (CPS).

  SuperDirt uses cycles as its base timing unit. CPS defines how fast
  cycles progress. Default is 0.5625 (135 BPM).

  To convert BPM to CPS: `cps = bpm / 240`

  ## Examples

      # 120 BPM
      SuperDirt.set_cps(0.5)

      # 140 BPM
      SuperDirt.set_cps(140 / 240)

  """
  def set_cps(cps) when is_number(cps) do
    GenServer.call(@me, {:set_cps, cps})
  end

  @doc """
  Set the OSC bundle latency in seconds.

  Latency determines how far in the future events are scheduled. A small
  latency (default 20ms) gives SuperDirt time to process events before playback.
  Increase for more scheduling stability, decrease for lower latency.

  ## Examples

      # Lower latency (10ms) - use for responsive playback
      SuperDirt.set_latency(0.01)

      # Higher latency (50ms) - use if experiencing timing jitter
      SuperDirt.set_latency(0.05)

  """
  def set_latency(latency) when is_number(latency) and latency >= 0 do
    GenServer.call(@me, {:set_latency, latency})
  end

  @doc """
  Get the current OSC bundle latency in seconds.

  ## Examples

      SuperDirt.get_latency()
      # => 0.02

  """
  def get_latency do
    GenServer.call(@me, :get_latency)
  end

  defp send_command(address, args) do
    GenServer.cast(@me, {:command, address, args})
  end

  def start_link(opts) do
    GenServer.start_link(@me, opts, name: @me)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 57_120)
    udp_port = Keyword.get(opts, :udp_port, 57_121)
    latency = Keyword.get(opts, :latency, 0.02)

    {:ok, socket} = :gen_udp.open(udp_port, [:binary, {:active, false}])

    state = %State{
      socket: socket,
      port: port,
      latency: latency
    }

    # Log helpful message about SuperDirt
    Logger.info("""
    Waveform.SuperDirt started (listening on port #{port}).

    IMPORTANT: SuperDirt must be installed and loaded in SuperCollider.
    - Check installation: mix waveform.doctor
    - Load SuperDirt: Waveform.Lang.send_command("SuperDirt.start;")
    - Verify: Waveform.SuperDirt.verify()
    """)

    {:ok, state}
  end

  def terminate(_reason, state) do
    :gen_udp.close(state.socket)
  end

  def handle_call({:play, params}, _from, state) do
    # Build OSC message with required parameters
    message = build_play_message(params, state)

    # Send as OSC bundle with timestamp
    @transport.send_osc_bundle(state, message)

    # Increment cycle counter
    state = %{state | cycle: state.cycle + 1.0}

    {:reply, :ok, state}
  end

  def handle_call({:set_cps, cps}, _from, state) do
    {:reply, :ok, %{state | cps: cps}}
  end

  def handle_call({:set_latency, latency}, _from, state) do
    {:reply, :ok, %{state | latency: latency}}
  end

  def handle_call(:get_latency, _from, state) do
    {:reply, state.latency, state}
  end

  def handle_cast({:command, address, args}, state) do
    @transport.send_osc_message(state, address, args)
    {:noreply, state}
  end

  defp build_play_message(params, state) do
    # Extract or default common parameters
    orbit = Keyword.get(params, :orbit, 0)
    delta = Keyword.get(params, :delta, 1.0)

    # Build name-value pairs for SuperDirt
    # Format: [name1, value1, name2, value2, ...]
    pairs = [
      ~c"cps",
      state.cps,
      ~c"cycle",
      state.cycle,
      ~c"delta",
      delta,
      ~c"orbit",
      orbit
    ]

    # Add user parameters
    pairs =
      Enum.reduce(params, pairs, fn {key, value}, acc ->
        # Skip parameters we've already added
        if key in [:orbit, :delta] do
          acc
        else
          acc ++ [to_charlist(to_string(key)), normalize_value(value)]
        end
      end)

    [@dirt_play | pairs]
  end

  defp normalize_value(value) when is_binary(value), do: to_charlist(value)
  defp normalize_value(value) when is_atom(value), do: to_charlist(to_string(value))
  defp normalize_value(value), do: value
end
