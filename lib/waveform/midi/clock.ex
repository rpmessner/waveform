defmodule Waveform.MIDI.Clock do
  @moduledoc """
  MIDI clock synchronization for sending and receiving MIDI clock messages.

  MIDI clock uses 24 pulses per quarter note (PPQ). This module can operate in two modes:

  - **Master mode**: Send clock messages to external MIDI devices
  - **Slave mode**: Receive clock messages from an external master and sync PatternScheduler

  ## MIDI Clock Messages

  - `0xF8` - Timing Clock (24 per quarter note)
  - `0xFA` - Start
  - `0xFB` - Continue
  - `0xFC` - Stop
  - `0xF2` - Song Position Pointer (optional)

  ## Master Mode (Sending Clock)

  Send clock to drive external hardware/software:

      alias Waveform.MIDI.Clock

      # Start sending clock at 120 BPM
      Clock.start_master(120)

      # Change tempo
      Clock.set_bpm(140)

      # Transport controls (sends start/stop/continue messages)
      Clock.send_start()
      Clock.send_stop()
      Clock.send_continue()

      # Stop sending clock
      Clock.stop_master()

  ## Slave Mode (Receiving Clock)

  Sync to external MIDI clock:

      # Start listening for clock on a port
      Clock.start_slave("USB MIDI Keyboard")

      # Clock will automatically sync PatternScheduler tempo
      # When external device sends Start, patterns will start
      # When external device sends Stop, patterns will stop

      # Stop listening
      Clock.stop_slave()

  ## Integration with PatternScheduler

  When in slave mode, the Clock module automatically:
  - Calculates BPM from incoming clock messages
  - Updates PatternScheduler.set_cps() with calculated tempo
  - Triggers hush() on Stop message
  - (Future: triggers pattern start on Start message)

  ## Configuration

      config :waveform,
        midi_clock_port: "IAC Driver Bus 1",  # Default clock output port
        midi_clock_smoothing: 8               # Number of ticks to average for BPM calc

  """

  use GenServer
  require Logger
  import Bitwise

  alias Waveform.MIDI.Input
  alias Waveform.MIDI.Port

  @me __MODULE__

  # MIDI System Real-Time Messages
  @clock_tick 0xF8
  @start_msg 0xFA
  @continue_msg 0xFB
  @stop_msg 0xFC
  @song_position 0xF2

  # MIDI clock sends 24 pulses per quarter note
  @ppq 24

  defmodule State do
    @moduledoc false
    defstruct [
      # Master mode state
      :master_timer,
      :master_port,
      :bpm,
      :tick_interval_us,
      # Slave mode state
      :slave_port,
      :last_tick_time,
      :tick_times,
      :smoothing_window,
      :running,
      # Calculated from incoming clock
      :calculated_bpm
    ]
  end

  # Client API

  @doc """
  Starts the MIDI clock GenServer.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(@me, opts, name: @me)
  end

  # --- Master Mode (Sending Clock) ---

  @doc """
  Start sending MIDI clock at the specified BPM.

  ## Options

  - `:port` - MIDI port to send clock on (default: from config or first available)

  ## Examples

      Clock.start_master(120)
      Clock.start_master(140, port: "IAC Driver Bus 1")

  """
  def start_master(bpm, opts \\ []) when is_number(bpm) and bpm > 0 do
    GenServer.call(@me, {:start_master, bpm, opts})
  end

  @doc """
  Stop sending MIDI clock.
  """
  def stop_master do
    GenServer.call(@me, :stop_master)
  end

  @doc """
  Set the BPM for master clock output.

  Takes effect immediately for the next tick.
  """
  def set_bpm(bpm) when is_number(bpm) and bpm > 0 do
    GenServer.call(@me, {:set_bpm, bpm})
  end

  @doc """
  Get the current BPM (master mode: set value, slave mode: calculated value).
  """
  def get_bpm do
    GenServer.call(@me, :get_bpm)
  end

  @doc """
  Send MIDI Start message (0xFA).

  Tells receivers to start playback from the beginning.
  """
  def send_start do
    GenServer.cast(@me, :send_start)
  end

  @doc """
  Send MIDI Stop message (0xFC).

  Tells receivers to stop playback.
  """
  def send_stop do
    GenServer.cast(@me, :send_stop)
  end

  @doc """
  Send MIDI Continue message (0xFB).

  Tells receivers to resume playback from current position.
  """
  def send_continue do
    GenServer.cast(@me, :send_continue)
  end

  @doc """
  Send Song Position Pointer (0xF2).

  Position is in MIDI beats (1 beat = 6 MIDI clocks).

  ## Examples

      # Go to beat 0 (beginning)
      Clock.send_position(0)

      # Go to beat 16 (4 bars in 4/4)
      Clock.send_position(16 * 4)

  """
  def send_position(midi_beats) when is_integer(midi_beats) and midi_beats >= 0 do
    GenServer.cast(@me, {:send_position, midi_beats})
  end

  # --- Slave Mode (Receiving Clock) ---

  @doc """
  Start receiving MIDI clock from a port.

  Will sync PatternScheduler tempo to incoming clock.

  ## Options

  - `:sync_scheduler` - Whether to sync PatternScheduler (default: true)

  ## Examples

      Clock.start_slave("USB MIDI Keyboard")
      Clock.start_slave("IAC Driver Bus 1", sync_scheduler: false)

  """
  def start_slave(port_name, opts \\ []) do
    GenServer.call(@me, {:start_slave, port_name, opts})
  end

  @doc """
  Stop receiving MIDI clock.
  """
  def stop_slave do
    GenServer.call(@me, :stop_slave)
  end

  @doc """
  Check if clock is running (receiving Start without Stop).
  """
  def running? do
    GenServer.call(@me, :running?)
  end

  # Server Implementation

  @impl true
  def init(opts) do
    smoothing = Keyword.get(opts, :smoothing_window, 8)

    state = %State{
      bpm: 120.0,
      tick_interval_us: bpm_to_tick_interval(120.0),
      tick_times: [],
      smoothing_window: smoothing,
      running: false
    }

    {:ok, state}
  end

  # --- Master Mode Handlers ---

  @impl true
  def handle_call({:start_master, bpm, opts}, _from, state) do
    # Stop existing master if running
    state = stop_master_timer(state)

    port_name = Keyword.get(opts, :port)

    case get_master_connection(port_name) do
      {:ok, conn} ->
        tick_interval_us = bpm_to_tick_interval(bpm)

        new_state = %{
          state
          | master_port: conn,
            bpm: bpm,
            tick_interval_us: tick_interval_us
        }

        # Start the clock tick loop
        new_state = schedule_master_tick(new_state)
        Logger.info("MIDI Clock master started at #{bpm} BPM")
        {:reply, :ok, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:stop_master, _from, state) do
    new_state = stop_master_timer(state)
    Logger.info("MIDI Clock master stopped")
    {:reply, :ok, %{new_state | master_port: nil}}
  end

  @impl true
  def handle_call({:set_bpm, bpm}, _from, state) do
    tick_interval_us = bpm_to_tick_interval(bpm)
    {:reply, :ok, %{state | bpm: bpm, tick_interval_us: tick_interval_us}}
  end

  @impl true
  def handle_call(:get_bpm, _from, state) do
    bpm = state.calculated_bpm || state.bpm
    {:reply, bpm, state}
  end

  # --- Slave Mode Handlers ---

  @impl true
  def handle_call({:start_slave, port_name, opts}, _from, state) do
    sync_scheduler = Keyword.get(opts, :sync_scheduler, true)

    case Input.listen(port_name) do
      :ok ->
        Input.on_all(&dispatch_clock_event(&1, sync_scheduler))
        Logger.info("MIDI Clock slave listening on #{port_name}")
        {:reply, :ok, %{state | slave_port: port_name}}

      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:stop_slave, _from, state) do
    if state.slave_port do
      Input.stop()
      Input.clear_handlers()
    end

    Logger.info("MIDI Clock slave stopped")
    {:reply, :ok, %{state | slave_port: nil, last_tick_time: nil, tick_times: []}}
  end

  @impl true
  def handle_call(:running?, _from, state) do
    {:reply, state.running, state}
  end

  # --- Transport Message Handlers (Master) ---

  @impl true
  def handle_cast(:send_start, state) do
    if state.master_port do
      Midiex.send_msg(state.master_port, <<@start_msg>>)
    end

    {:noreply, %{state | running: true}}
  end

  @impl true
  def handle_cast(:send_stop, state) do
    if state.master_port do
      Midiex.send_msg(state.master_port, <<@stop_msg>>)
    end

    {:noreply, %{state | running: false}}
  end

  @impl true
  def handle_cast(:send_continue, state) do
    if state.master_port do
      Midiex.send_msg(state.master_port, <<@continue_msg>>)
    end

    {:noreply, %{state | running: true}}
  end

  @impl true
  def handle_cast({:send_position, midi_beats}, state) do
    if state.master_port do
      # Song Position is in MIDI beats (1 beat = 6 clocks)
      # Encoded as 14-bit value (LSB, MSB)
      position = min(midi_beats, 16_383)
      lsb = position &&& 0x7F
      msb = (position >>> 7) &&& 0x7F
      Midiex.send_msg(state.master_port, <<@song_position, lsb, msb>>)
    end

    {:noreply, state}
  end

  # --- Clock Tick Handlers (Slave) ---

  @impl true
  def handle_cast({:clock_tick, sync_scheduler}, state) do
    now = System.monotonic_time(:microsecond)

    new_state =
      if state.last_tick_time do
        # Calculate interval since last tick
        interval = now - state.last_tick_time

        # Add to smoothing window
        tick_times = [interval | Enum.take(state.tick_times, state.smoothing_window - 1)]

        # Calculate average interval and derive BPM
        avg_interval = Enum.sum(tick_times) / length(tick_times)
        calculated_bpm = tick_interval_to_bpm(avg_interval)

        # Sync to PatternScheduler if enabled
        if sync_scheduler and length(tick_times) >= 4 do
          cps = calculated_bpm / 240.0
          Waveform.PatternScheduler.set_cps(cps)
        end

        %{
          state
          | last_tick_time: now,
            tick_times: tick_times,
            calculated_bpm: calculated_bpm
        }
      else
        %{state | last_tick_time: now}
      end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:transport, :start, sync_scheduler}, state) do
    Logger.info("MIDI Clock: Received Start")

    if sync_scheduler do
      # Could trigger pattern start here in future
    end

    {:noreply, %{state | running: true}}
  end

  @impl true
  def handle_cast({:transport, :stop, sync_scheduler}, state) do
    Logger.info("MIDI Clock: Received Stop")

    if sync_scheduler do
      Waveform.PatternScheduler.hush()
    end

    {:noreply, %{state | running: false, last_tick_time: nil, tick_times: []}}
  end

  @impl true
  def handle_cast({:transport, :continue, _sync_scheduler}, state) do
    Logger.info("MIDI Clock: Received Continue")
    {:noreply, %{state | running: true}}
  end

  # Handle unexpected messages gracefully
  @impl true
  def handle_cast({:clock_message, _status, _sync}, state) do
    {:noreply, state}
  end

  # --- Master Clock Tick Loop ---

  @impl true
  def handle_info(:master_tick, state) do
    if state.master_port do
      # Send clock tick
      Midiex.send_msg(state.master_port, <<@clock_tick>>)

      # Schedule next tick
      new_state = schedule_master_tick(state)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # --- Private Helpers ---

  defp dispatch_clock_event(%{type: :clock_tick}, sync), do: GenServer.cast(@me, {:clock_tick, sync})
  defp dispatch_clock_event(%{type: :start}, sync), do: GenServer.cast(@me, {:transport, :start, sync})
  defp dispatch_clock_event(%{type: :stop}, sync), do: GenServer.cast(@me, {:transport, :stop, sync})
  defp dispatch_clock_event(%{type: :continue}, sync), do: GenServer.cast(@me, {:transport, :continue, sync})
  defp dispatch_clock_event(_event, _sync), do: :ok

  defp bpm_to_tick_interval(bpm) do
    # BPM to microseconds per tick
    # 60 seconds / BPM = seconds per beat
    # seconds per beat / 24 = seconds per tick
    # * 1_000_000 = microseconds per tick
    seconds_per_beat = 60.0 / bpm
    seconds_per_tick = seconds_per_beat / @ppq
    round(seconds_per_tick * 1_000_000)
  end

  defp tick_interval_to_bpm(interval_us) do
    # Reverse of above
    seconds_per_tick = interval_us / 1_000_000
    seconds_per_beat = seconds_per_tick * @ppq
    60.0 / seconds_per_beat
  end

  defp schedule_master_tick(state) do
    # Use microsecond precision for accurate timing
    # Convert to milliseconds for Process.send_after (minimum 1ms)
    delay_ms = max(1, div(state.tick_interval_us, 1000))
    timer = Process.send_after(self(), :master_tick, delay_ms)
    %{state | master_timer: timer}
  end

  defp stop_master_timer(state) do
    if state.master_timer do
      Process.cancel_timer(state.master_timer)
    end

    %{state | master_timer: nil}
  end

  defp get_master_connection(nil) do
    # Use default clock port from config, or default MIDI port
    port_name = Application.get_env(:waveform, :midi_clock_port)

    if port_name do
      Port.get_output(port_name)
    else
      Port.get_default_output()
    end
  end

  defp get_master_connection(port_name) do
    Port.get_output(port_name)
  end
end
