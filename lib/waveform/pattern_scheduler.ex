defmodule Waveform.PatternScheduler do
  @moduledoc """
  High-precision pattern scheduler for continuous audio pattern playback.

  ## Concept: Cycle-Based Timing

  Instead of scheduling events at absolute times (e.g., "play at 10.5 seconds"),
  the scheduler uses **cycles** as the fundamental unit:

      Cycle 0.0 -----> 1.0 -----> 2.0 -----> 3.0
               [pattern loop]  [pattern loop]

  A pattern like "bd cp sd cp" (bass drum, clap, snare, clap) has 4 events
  distributed across one cycle:

  - Event 1: bd at cycle position 0.0
  - Event 2: cp at cycle position 0.25
  - Event 3: sd at cycle position 0.5
  - Event 4: cp at cycle position 0.75
  - (loops back to 0.0)

  ## Concept: Look-Ahead Scheduling

  The scheduler doesn't wait until the last moment to send events. Instead,
  it "looks ahead" into the future:

      Current time: 10.0 seconds
      Latency: 0.02 seconds (20ms)
      Look-ahead window: 10.0 to 10.02

      The scheduler asks: "What events fall in this window?"
      It schedules them NOW with timestamps for the future.

  This prevents timing jitter and ensures smooth playback.

  ## Concept: The Scheduling Loop

  The scheduler runs continuously:

      1. Calculate current cycle position (based on time and CPS)
      2. Look ahead by latency amount
      3. Find events in that cycle window
      4. Send to SuperDirt with precise timestamps
      5. Remember what we've already sent (don't duplicate)
      6. Schedule next tick
      7. Sleep and repeat

  ## Architecture

  The scheduler is a GenServer that manages:

  - **Patterns**: Map of pattern_id -> pattern_data
  - **Current cycle**: Where we are in musical time
  - **CPS**: Cycles per second (tempo)
  - **Tick rate**: How often we check for events to schedule
  - **Scheduled events**: What we've already sent (to avoid duplicates)

  ## Example Usage

      # Start the scheduler
      {:ok, _pid} = PatternScheduler.start_link([])

      # Set tempo (0.5625 CPS = 135 BPM)
      PatternScheduler.set_cps(0.5625)

      # Schedule a pattern
      # Events are a list of {cycle_position, params}
      events = [
        {0.0, [s: "bd"]},
        {0.25, [s: "cp"]},
        {0.5, [s: "sd"]},
        {0.75, [s: "cp"]}
      ]

      PatternScheduler.schedule_pattern(:drums, events)

      # Pattern now plays continuously, looping every cycle
      # To change it (hot-swap):
      new_events = [
        {0.0, [s: "bd", n: 1]},
        {0.5, [s: "bd", n: 2]}
      ]
      PatternScheduler.update_pattern(:drums, new_events)

      # Stop a pattern
      PatternScheduler.stop_pattern(:drums)

  ## Timing Precision

  The scheduler uses:
  - System.monotonic_time() for steady clock (doesn't jump)
  - Small tick intervals (default 10ms) for responsive scheduling
  - OSC bundle latency (20ms default) for audio stability
  - Cycle arithmetic to prevent drift over time

  """
  use GenServer
  require Logger

  @me __MODULE__

  # How often to check for events to schedule (milliseconds)
  # Smaller = more responsive but more CPU
  # Larger = less CPU but events might be late
  @default_tick_interval_ms 10

  # --- Data Structures ---

  defmodule State do
    @moduledoc """
    Scheduler state.

    ## Fields

    - `patterns` - Map of pattern_id -> Pattern struct
    - `cps` - Cycles per second (tempo)
    - `start_time` - Monotonic time when scheduler started (microseconds)
    - `tick_interval_ms` - How often to schedule (milliseconds)
    - `tick_timer` - Reference to current timer
    - `scheduled_events` - Set of event IDs already scheduled (to avoid duplicates)
    """
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
    @moduledoc """
    A pattern is a collection of events that repeat every cycle.

    ## Fields

    - `events` - List of {cycle_position, params} tuples (static patterns)
    - `query_fn` - Function (cycle_number) -> events (dynamic/cycle-aware patterns)
    - `active` - Whether this pattern is currently playing
    - `last_scheduled_cycle` - Last cycle we scheduled events for (prevents duplicates)
    - `output` - Output destination: `:superdirt`, `:midi`, or list like `[:superdirt, :midi]`
    - `output_opts` - Additional options for output (e.g., midi_channel, midi_port)

    Note: Either `events` OR `query_fn` should be set, not both.
    If `query_fn` is set, it takes precedence over `events`.
    """
    defstruct [
      :events,
      :query_fn,
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
  Schedule a new pattern or update an existing one.

  Accepts either a static event list or a query function for cycle-aware patterns.

  ## Static Events

  Events are a list of {cycle_position, params} tuples where:
  - cycle_position is a float from 0.0 to 1.0 (position within one cycle)
  - params is a keyword list for SuperDirt (e.g., [s: "bd", n: 0])

  The pattern will loop continuously until stopped.

  ## Query Functions (Cycle-Aware Patterns)

  For dynamic patterns that change based on cycle number, pass a function:

      query_fn :: (cycle_number :: integer) -> [{position, params}]

  The function receives the current cycle number (0, 1, 2, ...) and returns
  events for that specific cycle. This enables transformations like:
  - `every(4, rev)` - reverse the pattern every 4th cycle
  - `iter(4)` - rotate the pattern start point each cycle
  - Random variations per cycle

  ## Options

  - `:output` - Output destination: `:superdirt` (default), `:midi`, or `[:superdirt, :midi]`
  - `:midi_channel` - MIDI channel (1-16) for MIDI output
  - `:midi_port` - MIDI port name for MIDI output

  ## Examples

      # Simple kick pattern (4 on the floor) - SuperDirt output (default)
      PatternScheduler.schedule_pattern(:kick, [
        {0.0, [s: "bd"]},
        {0.25, [s: "bd"]},
        {0.5, [s: "bd"]},
        {0.75, [s: "bd"]}
      ])

      # MIDI melody pattern
      PatternScheduler.schedule_pattern(:melody, [
        {0.0, [note: 60, velocity: 80]},
        {0.25, [note: 64, velocity: 70]},
        {0.5, [note: 67, velocity: 90]}
      ], output: :midi, midi_channel: 1)

      # Send to both SuperDirt and MIDI
      PatternScheduler.schedule_pattern(:hybrid, events,
        output: [:superdirt, :midi],
        midi_channel: 10
      )

      # Cycle-aware pattern using query function
      # Alternates between two patterns every cycle
      PatternScheduler.schedule_pattern(:alternating, fn cycle ->
        if rem(cycle, 2) == 0 do
          [{0.0, [s: "bd"]}, {0.5, [s: "sd"]}]
        else
          [{0.0, [s: "hh"]}, {0.5, [s: "cp"]}]
        end
      end)

      # Pattern that only plays every 4th cycle
      PatternScheduler.schedule_pattern(:sparse, fn cycle ->
        if rem(cycle, 4) == 0 do
          [{0.0, [s: "bd", gain: 1.2]}]
        else
          []
        end
      end)

  """
  def schedule_pattern(pattern_id, events_or_fn, opts \\ [])

  # Static events with server as third arg (backward compat)
  def schedule_pattern(pattern_id, events, server)
      when is_list(events) and (is_atom(server) or is_pid(server)) do
    GenServer.call(server, {:schedule_pattern, pattern_id, events, []})
  end

  # Static events with options
  def schedule_pattern(pattern_id, events, opts) when is_list(events) and is_list(opts) do
    {server, opts} = Keyword.pop(opts, :server, @me)
    GenServer.call(server, {:schedule_pattern, pattern_id, events, opts})
  end

  # Query function with server as third arg
  def schedule_pattern(pattern_id, query_fn, server)
      when is_function(query_fn, 1) and (is_atom(server) or is_pid(server)) do
    GenServer.call(server, {:schedule_pattern_fn, pattern_id, query_fn, []})
  end

  # Query function with options
  def schedule_pattern(pattern_id, query_fn, opts) when is_function(query_fn, 1) and is_list(opts) do
    {server, opts} = Keyword.pop(opts, :server, @me)
    GenServer.call(server, {:schedule_pattern_fn, pattern_id, query_fn, opts})
  end

  @doc """
  Update an existing pattern with new events (hot-swap).

  This allows you to change a pattern while it's playing without stopping it.
  The new events take effect immediately.

  ## Examples

      # Change the kick pattern
      PatternScheduler.update_pattern(:kick, [
        {0.0, [s: "bd", n: 1]},
        {0.5, [s: "bd", n: 2]}
      ])
  """
  def update_pattern(pattern_id, events, server \\ @me) when is_list(events) do
    GenServer.call(server, {:update_pattern, pattern_id, events})
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
    # Update tempo - affects all future scheduling
    # Already-scheduled events keep their timestamps
    {:reply, :ok, %{state | cps: cps}}
  end

  def handle_call({:schedule_pattern, pattern_id, events}, from, state) do
    # Backward compatibility: no options provided
    handle_call({:schedule_pattern, pattern_id, events, []}, from, state)
  end

  def handle_call({:schedule_pattern, pattern_id, events, opts}, _from, state) do
    # Extract output configuration
    output = Keyword.get(opts, :output, :superdirt)
    output_opts = Keyword.drop(opts, [:output])

    # Create new pattern or replace existing one
    pattern = %Pattern{
      events: events,
      query_fn: nil,
      active: true,
      # Fresh start
      last_scheduled_cycle: nil,
      output: output,
      output_opts: output_opts
    }

    new_patterns = Map.put(state.patterns, pattern_id, pattern)
    {:reply, :ok, %{state | patterns: new_patterns}}
  end

  def handle_call({:schedule_pattern_fn, pattern_id, query_fn, opts}, _from, state) do
    # Extract output configuration
    output = Keyword.get(opts, :output, :superdirt)
    output_opts = Keyword.drop(opts, [:output])

    # Create pattern with query function instead of static events
    pattern = %Pattern{
      events: nil,
      query_fn: query_fn,
      active: true,
      last_scheduled_cycle: nil,
      output: output,
      output_opts: output_opts
    }

    new_patterns = Map.put(state.patterns, pattern_id, pattern)
    {:reply, :ok, %{state | patterns: new_patterns}}
  end

  def handle_call({:update_pattern, pattern_id, events}, from, state) do
    # Hot-swap: update events while keeping pattern active
    case Map.get(state.patterns, pattern_id) do
      nil ->
        # Pattern doesn't exist, create it
        handle_call({:schedule_pattern, pattern_id, events}, from, state)

      pattern ->
        # Update events, reset cycle tracking
        updated_pattern = %{pattern | events: events, last_scheduled_cycle: nil}
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

  # Get events from pattern - either static events or via query function
  defp get_pattern_events(%Pattern{query_fn: query_fn}, current_cycle)
       when is_function(query_fn, 1) do
    # Query for the current cycle's events
    cycle_int = floor(current_cycle)
    query_fn.(cycle_int)
  end

  defp get_pattern_events(%Pattern{events: events}, _current_cycle) when is_list(events) do
    events
  end

  defp get_pattern_events(%Pattern{events: nil, query_fn: nil}, _current_cycle) do
    # No events and no query function - return empty list
    []
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
      # New event! Send it to the configured output(s)
      send_event(pattern, params)

      # Mark as scheduled
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
