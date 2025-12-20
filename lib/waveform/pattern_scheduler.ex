defmodule Waveform.PatternScheduler do
  @moduledoc """
  High-precision pattern scheduler for continuous audio pattern playback.

  Works directly with UzuPattern patterns for cycle-based scheduling.

  ## Concept: Cycle-Based Timing

  The scheduler uses **cycles** as the fundamental unit:

      Cycle 0.0 -----> 1.0 -----> 2.0 -----> 3.0
               [pattern loop]  [pattern loop]

  A pattern like "bd cp sd cp" has 4 events distributed across one cycle:

  - bd at cycle position 0.0
  - cp at cycle position 0.25
  - sd at cycle position 0.5
  - cp at cycle position 0.75

  ## Example Usage

      # Start the scheduler
      {:ok, _pid} = PatternScheduler.start_link([])

      # Set tempo (0.5625 CPS = 135 BPM)
      PatternScheduler.set_cps(0.5625)

      # Schedule a pattern using UzuPattern
      pattern = UzuPattern.parse("bd cp sd cp")
      PatternScheduler.schedule_pattern(:drums, pattern)

      # Apply transformations
      pattern =
        UzuPattern.parse("bd sd hh cp")
        |> UzuPattern.Pattern.fast(2)
        |> UzuPattern.Pattern.every(4, &UzuPattern.Pattern.rev/1)

      PatternScheduler.schedule_pattern(:drums, pattern)

      # Hot-swap to new pattern
      new_pattern = UzuPattern.parse("bd bd sd sd")
      PatternScheduler.update_pattern(:drums, new_pattern)

      # Stop a pattern
      PatternScheduler.stop_pattern(:drums)

  ## Timing Precision

  The scheduler uses:
  - System.monotonic_time() for steady clock
  - Small tick intervals (default 10ms) for responsive scheduling
  - OSC bundle latency (20ms default) for audio stability
  - Cycle arithmetic to prevent drift over time
  """
  use GenServer
  require Logger

  alias UzuPattern.Pattern, as: UzuPatternMod

  @me __MODULE__

  # How often to check for events to schedule (milliseconds)
  @default_tick_interval_ms 10

  # --- Data Structures ---

  defmodule State do
    @moduledoc false
    defstruct [
      :patterns,
      :cps,
      :start_time,
      :tick_interval_ms,
      :tick_timer,
      :scheduled_events
    ]
  end

  defmodule Pattern do
    @moduledoc false
    defstruct [
      :uzu_pattern,
      :active,
      :last_scheduled_cycle,
      output: :superdirt,
      output_opts: []
    ]
  end

  # --- Public API ---

  @doc """
  Start the pattern scheduler.

  ## Options

  - `:cps` - Cycles per second (default: 0.5625 = 135 BPM)
  - `:tick_interval_ms` - How often to check for events (default: 10ms)
  - `:name` - Process name (default: #{__MODULE__})
  """
  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name, @me)
    GenServer.start_link(@me, opts, name: name)
  end

  @doc """
  Set the global tempo in cycles per second.

  ## Examples

      # 120 BPM
      PatternScheduler.set_cps(0.5)

      # 140 BPM
      PatternScheduler.set_cps(140 / 240)
  """
  def set_cps(cps, server \\ @me) when is_number(cps) and cps > 0 do
    GenServer.call(server, {:set_cps, cps})
  end

  @doc """
  Schedule an UzuPattern for playback.

  ## Options

  - `:output` - Output destination: `:superdirt` (default), `:midi`, or `[:superdirt, :midi]`
  - `:midi_channel` - MIDI channel (1-16) for MIDI output
  - `:midi_port` - MIDI port name for MIDI output

  ## Examples

      # Parse and schedule a pattern
      pattern = UzuPattern.parse("bd cp sd cp")
      PatternScheduler.schedule_pattern(:drums, pattern)

      # With transformations
      pattern =
        UzuPattern.parse("bd sd hh cp")
        |> UzuPattern.Pattern.fast(2)

      PatternScheduler.schedule_pattern(:drums, pattern)

      # MIDI output
      pattern = UzuPattern.parse("60 64 67")
      PatternScheduler.schedule_pattern(:melody, pattern,
        output: :midi,
        midi_channel: 1
      )
  """
  def schedule_pattern(pattern_id, uzu_pattern, opts \\ [])

  def schedule_pattern(pattern_id, %UzuPattern.Pattern{} = uzu_pattern, server)
      when is_atom(server) or is_pid(server) do
    GenServer.call(server, {:schedule_pattern, pattern_id, uzu_pattern, []})
  end

  def schedule_pattern(pattern_id, %UzuPattern.Pattern{} = uzu_pattern, opts)
      when is_list(opts) do
    {server, opts} = Keyword.pop(opts, :server, @me)
    GenServer.call(server, {:schedule_pattern, pattern_id, uzu_pattern, opts})
  end

  @doc """
  Update an existing pattern (hot-swap).

  The new pattern takes effect immediately.

  ## Examples

      new_pattern = UzuPattern.parse("bd bd sd sd")
      PatternScheduler.update_pattern(:drums, new_pattern)
  """
  def update_pattern(pattern_id, %UzuPattern.Pattern{} = uzu_pattern, server \\ @me) do
    GenServer.call(server, {:update_pattern, pattern_id, uzu_pattern})
  end

  @doc """
  Stop a pattern from playing.

  ## Examples

      PatternScheduler.stop_pattern(:kick)
  """
  def stop_pattern(pattern_id, server \\ @me) do
    GenServer.call(server, {:stop_pattern, pattern_id})
  end

  @doc """
  Stop all patterns.

  ## Examples

      PatternScheduler.hush()
  """
  def hush do
    GenServer.call(@me, :hush)
  end

  # --- GenServer Callbacks ---

  def init(opts) do
    # Use monotonic time for steady clock (doesn't jump with system time changes)
    start_time = System.monotonic_time(:microsecond)

    cps = Keyword.get(opts, :cps, 0.5625)
    tick_interval_ms = Keyword.get(opts, :tick_interval_ms, @default_tick_interval_ms)

    state = %State{
      patterns: %{},
      cps: cps,
      start_time: start_time,
      tick_interval_ms: tick_interval_ms,
      tick_timer: nil,
      scheduled_events: MapSet.new()
    }

    # Start the scheduling loop
    {:ok, schedule_next_tick(state)}
  end

  def handle_call({:set_cps, cps}, _from, state) do
    {:reply, :ok, %{state | cps: cps}}
  end

  def handle_call(
        {:schedule_pattern, pattern_id, %UzuPattern.Pattern{} = uzu_pattern, opts},
        _from,
        state
      ) do
    output = Keyword.get(opts, :output, :superdirt)
    output_opts = Keyword.drop(opts, [:output])

    pattern = %Pattern{
      uzu_pattern: uzu_pattern,
      active: true,
      last_scheduled_cycle: nil,
      output: output,
      output_opts: output_opts
    }

    new_patterns = Map.put(state.patterns, pattern_id, pattern)
    {:reply, :ok, %{state | patterns: new_patterns}}
  end

  def handle_call({:update_pattern, pattern_id, %UzuPattern.Pattern{} = uzu_pattern}, from, state) do
    case Map.get(state.patterns, pattern_id) do
      nil ->
        handle_call({:schedule_pattern, pattern_id, uzu_pattern, []}, from, state)

      pattern ->
        updated_pattern = %{pattern | uzu_pattern: uzu_pattern, last_scheduled_cycle: nil}
        new_patterns = Map.put(state.patterns, pattern_id, updated_pattern)
        {:reply, :ok, %{state | patterns: new_patterns}}
    end
  end

  def handle_call({:stop_pattern, pattern_id}, _from, state) do
    # Remove pattern from active patterns
    new_patterns = Map.delete(state.patterns, pattern_id)
    {:reply, :ok, %{state | patterns: new_patterns}}
  end

  def handle_call(:hush, _from, state) do
    # Stop all patterns and tell SuperDirt to hush
    Waveform.SuperDirt.hush()
    {:reply, :ok, %{state | patterns: %{}, scheduled_events: MapSet.new()}}
  end

  # --- The Scheduling Loop (This is the heart!) ---

  def handle_info(:tick, state) do
    # This runs every tick_interval_ms (default 10ms)
    # It's the core scheduling loop

    # Step 1: Calculate where we are in musical time
    current_cycle = calculate_current_cycle(state)

    # Step 2: Calculate where we'll be after latency
    latency_seconds =
      if Process.whereis(Waveform.SuperDirt) do
        Waveform.SuperDirt.get_latency()
      else
        # Default latency if SuperDirt not running
        0.02
      end

    latency_cycles = latency_seconds * state.cps
    look_ahead_cycle = current_cycle + latency_cycles

    # Step 3: Schedule all events in the look-ahead window
    new_state = schedule_events_in_window(state, current_cycle, look_ahead_cycle)

    # Step 4: Schedule next tick
    {:noreply, schedule_next_tick(new_state)}
  end

  # --- Helper Functions ---

  # Calculate current cycle position based on elapsed time.
  #
  # How it works:
  #   elapsed_time = now - start_time (in seconds)
  #   current_cycle = elapsed_time * cps
  #
  # Example:
  #   - Started 10 seconds ago
  #   - CPS = 0.5 (one cycle every 2 seconds)
  #   - Current cycle = 10 * 0.5 = 5.0
  defp calculate_current_cycle(state) do
    now = System.monotonic_time(:microsecond)
    elapsed_microseconds = now - state.start_time
    elapsed_seconds = elapsed_microseconds / 1_000_000.0
    elapsed_seconds * state.cps
  end

  # Schedule all pattern events that fall within the cycle window.
  #
  # This is the core scheduling algorithm:
  # 1. For each active pattern:
  #    2. For each event in the pattern:
  #       3. Calculate which cycle(s) the event occurs in
  #       4. If it's in our window and not already scheduled:
  #          5. Calculate exact timestamp
  #          6. Send to SuperDirt
  #          7. Mark as scheduled
  defp schedule_events_in_window(state, current_cycle, look_ahead_cycle) do
    # Process each pattern
    Enum.reduce(state.patterns, state, fn {pattern_id, pattern}, acc_state ->
      if pattern.active do
        schedule_pattern_events(acc_state, pattern_id, pattern, current_cycle, look_ahead_cycle)
      else
        acc_state
      end
    end)
  end

  defp schedule_pattern_events(state, pattern_id, pattern, current_cycle, look_ahead_cycle) do
    # Get events - either static or from query function
    events = get_pattern_events(pattern, current_cycle)

    # For each event in the pattern
    Enum.reduce(events, state, fn {cycle_position, params}, acc_state ->
      # Find all occurrences of this event in the look-ahead window
      schedule_event_occurrences(
        acc_state,
        pattern_id,
        pattern,
        cycle_position,
        params,
        current_cycle,
        look_ahead_cycle
      )
    end)
  end

  # Query UzuPattern for events in the current cycle
  defp get_pattern_events(%Pattern{uzu_pattern: uzu_pattern}, current_cycle) do
    cycle_int = floor(current_cycle)

    uzu_pattern
    |> UzuPatternMod.query(cycle_int)
    |> Enum.map(&convert_hap/1)
  end

  # Convert UzuPattern.Hap to Waveform's {cycle_position, params} format
  defp convert_hap(%UzuPattern.Hap{} = hap) do
    # Use whole.begin for onset time (when to trigger the sound)
    onset = UzuPattern.Hap.onset(hap) || hap.part.begin

    # Convert Ratio to float for scheduling arithmetic
    onset_float = UzuPattern.Time.to_float(onset)

    # hap.value is a map with :s, :n, and other params
    params = Map.to_list(hap.value)

    {onset_float, params}
  end

  # Schedule all occurrences of an event in the cycle window.
  #
  # An event at cycle_position 0.25 occurs at:
  # - Cycle 0.25, 1.25, 2.25, 3.25, etc.
  #
  # We need to find which of these fall in [current_cycle, look_ahead_cycle]
  defp schedule_event_occurrences(
         state,
         pattern_id,
         pattern,
         cycle_position,
         params,
         current_cycle,
         look_ahead_cycle
       ) do
    # Calculate the cycle number of the first occurrence at or after current_cycle
    first_cycle_int = Float.floor(current_cycle)
    first_occurrence = first_cycle_int + cycle_position

    # If the first occurrence is before our window, try the next cycle
    first_occurrence =
      if first_occurrence < current_cycle do
        first_occurrence + 1.0
      else
        first_occurrence
      end

    # Schedule all occurrences in the window
    # (Usually just one, but could be multiple if tick_interval is large)
    schedule_occurrence_loop(
      state,
      pattern_id,
      pattern,
      cycle_position,
      params,
      first_occurrence,
      look_ahead_cycle
    )
  end

  defp schedule_occurrence_loop(
         state,
         _pattern_id,
         _pattern,
         _cycle_position,
         _params,
         event_cycle,
         look_ahead_cycle
       )
       when event_cycle > look_ahead_cycle do
    # Past the window, done
    state
  end

  defp schedule_occurrence_loop(
         state,
         pattern_id,
         pattern,
         cycle_position,
         params,
         event_cycle,
         look_ahead_cycle
       ) do
    # Create unique ID for this event occurrence
    event_id = {pattern_id, event_cycle, cycle_position}

    # Check if we've already scheduled this
    if MapSet.member?(state.scheduled_events, event_id) do
      # Already sent, skip to next occurrence
      schedule_occurrence_loop(
        state,
        pattern_id,
        pattern,
        cycle_position,
        params,
        event_cycle + 1.0,
        look_ahead_cycle
      )
    else
      cycle_int = Float.floor(event_cycle) |> trunc()

      # Check for division param - division stretches the pattern over N cycles
      # e.g., [sd sd]/2 with events at 0.0 and 0.5:
      #   - Event at 0.0: scaled_pos=0.0, plays on cycles where (cycle % 2) == 0
      #   - Event at 0.5: scaled_pos=1.0, plays on cycles where (cycle % 2) == 1
      division = Keyword.get(params, :division) || 1

      should_play =
        if division > 1 do
          scaled_pos = cycle_position * division
          event_cycle_offset = trunc(Float.floor(scaled_pos))
          cycle_within_iteration = rem(cycle_int, trunc(division))
          event_cycle_offset == cycle_within_iteration
        else
          true
        end

      if should_play do
        # Apply cycle-aware param transformations
        clean_params =
          params
          |> apply_alternation(cycle_int)
          |> Keyword.delete(:division)

        # New event! Send it to the configured output(s)
        send_event(pattern, clean_params)
      end

      # Mark as scheduled (even if skipped due to division)
      new_scheduled_events = MapSet.put(state.scheduled_events, event_id)
      new_state = %{state | scheduled_events: new_scheduled_events}

      # Check next occurrence
      schedule_occurrence_loop(
        new_state,
        pattern_id,
        pattern,
        cycle_position,
        params,
        event_cycle + 1.0,
        look_ahead_cycle
      )
    end
  end

  # Apply alternation: pick sound based on cycle number.
  # For <bd sd hh>, cycle 0 plays bd, cycle 1 plays sd, cycle 2 plays hh, cycle 3 plays bd, etc.
  defp apply_alternation(params, cycle_int) do
    case Keyword.get(params, :alternate) do
      nil ->
        params

      alternates when is_list(alternates) ->
        # Pick based on cycle (modulo number of alternatives)
        index = rem(cycle_int, length(alternates))
        selected = Enum.at(alternates, index)

        # Replace sound with selected alternative
        params
        |> update_sound_from_alternate(selected)
        |> Keyword.delete(:alternate)
    end
  end

  # Update the :s param with the selected alternate sound
  defp update_sound_from_alternate(params, %{sound: sound, sample: sample}) do
    params = Keyword.put(params, :s, sound)

    if sample do
      Keyword.put(params, :n, sample)
    else
      params
    end
  end

  defp update_sound_from_alternate(params, _), do: params

  # Send a single event to the configured output(s).
  #
  # Routes to SuperDirt, MIDI, or both based on pattern configuration.
  defp send_event(pattern, params) do
    case pattern.output do
      :superdirt ->
        send_to_superdirt(params)

      :midi ->
        send_to_midi(params, pattern.output_opts)

      outputs when is_list(outputs) ->
        Enum.each(outputs, fn
          :superdirt -> send_to_superdirt(params)
          :midi -> send_to_midi(params, pattern.output_opts)
        end)
    end
  end

  defp send_to_superdirt(params) do
    # SuperDirt.play already handles timestamps via OSC bundles
    Waveform.SuperDirt.play(params)
  end

  defp send_to_midi(params, output_opts) do
    # Map pattern-level options to MIDI param names
    # :midi_port -> :port, :midi_channel -> :channel
    midi_opts =
      output_opts
      |> Keyword.take([:midi_port, :midi_channel])
      |> Enum.map(fn
        {:midi_port, v} -> {:port, v}
        {:midi_channel, v} -> {:channel, v}
      end)

    # Merge: midi_opts (pattern-level) <- params (event-level takes precedence)
    merged_params =
      midi_opts
      |> Keyword.merge(params)

    Waveform.MIDI.play(merged_params)
  end

  # Schedule the next tick of the scheduling loop.
  #
  # Uses Process.send_after for precise timing.
  defp schedule_next_tick(state) do
    # Cancel old timer if it exists
    if state.tick_timer do
      Process.cancel_timer(state.tick_timer)
    end

    # Schedule next tick
    timer = Process.send_after(self(), :tick, state.tick_interval_ms)
    %{state | tick_timer: timer}
  end

  def terminate(_reason, state) do
    # Clean up timer on shutdown
    if state.tick_timer do
      Process.cancel_timer(state.tick_timer)
    end

    :ok
  end
end
