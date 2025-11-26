defmodule Waveform.MIDI do
  @moduledoc """
  MIDI output for Waveform.PatternScheduler.

  Parallel to Waveform.SuperDirt (OSC output). Converts pattern events
  to MIDI messages and sends them to configured MIDI ports.

  ## Event Format

  Events use the same format as SuperDirt:

      {cycle_position, [
        note: 60,           # MIDI note number (0-127)
        velocity: 80,       # MIDI velocity (0-127)
        channel: 1,         # MIDI channel (1-16, default: 1)
        duration_ms: 250,   # Note duration in milliseconds
        port: "IAC Driver"  # MIDI port name (optional)
      ]}

  ## Parameter Mapping

  - `:note` or `:n` → MIDI note number (0-127)
  - `:velocity` → MIDI velocity (0-127, direct)
  - `:gain` or `:amp` → Converted to velocity (0.0-1.0 → 0-127) using velocity curve
  - `:channel` → MIDI channel (1-16, default: 1)
  - `:duration_ms` → Note length in milliseconds (schedules note-off)
  - `:port` → MIDI port name or alias atom (default: from config)

  ## Port Routing

  You can route MIDI to different ports using aliases or full port names:

      # Configure port aliases
      config :waveform,
        midi_ports: %{
          drums: "IAC Driver Bus 1",
          synth: "USB MIDI Device"
        }

      # Use alias in play
      Waveform.MIDI.play(note: 36, port: :drums)

      # Use full port name
      Waveform.MIDI.play(note: 60, port: "USB MIDI Device")

      # Per-pattern port via PatternScheduler
      PatternScheduler.schedule_pattern(:melody, events,
        output: :midi,
        midi_port: :synth
      )

      # Per-event port override
      events = [
        {0.0, [note: 36, port: :drums]},   # This event goes to drums port
        {0.5, [note: 60, port: :synth]}    # This event goes to synth port
      ]

  ## Velocity Curves

  When using `:gain` or `:amp`, the value is converted to MIDI velocity using a curve:

  - `:linear` (default) - Direct mapping: gain 0.5 → velocity 64
  - `:exponential` - More musical feel: quiet values stay quieter longer

  Configure via:

      config :waveform, midi_velocity_curve: :exponential

  ## Configuration

      config :waveform,
        midi_port: "IAC Driver Bus 1",
        midi_default_channel: 1,
        midi_default_velocity: 100,
        midi_velocity_curve: :linear  # or :exponential

  ## Usage

      # Single MIDI note
      Waveform.MIDI.play(note: 60, velocity: 80, channel: 1)

      # With duration (auto note-off after 500ms)
      Waveform.MIDI.play(note: 60, velocity: 80, duration_ms: 500)

      # Raw note on/off
      Waveform.MIDI.note_on(60, 80, 1)
      Waveform.MIDI.note_off(60, 1)

      # All notes off (panic)
      Waveform.MIDI.all_notes_off()

  """

  alias Waveform.MIDI.Port
  alias Waveform.MIDI.Scheduler

  # MIDI message status bytes
  @note_off 0x80
  @note_on 0x90
  @control_change 0xB0
  @program_change 0xC0

  @doc """
  Plays a MIDI event from pattern parameters.

  Converts pattern event parameters to MIDI messages and sends them.
  Handles parameter mapping from various formats (`:note`, `:n`, `:velocity`, `:gain`, etc.)

  ## Parameters

  - `:note` or `:n` - MIDI note number (0-127), required
  - `:velocity` - MIDI velocity (0-127), default: 100
  - `:gain` or `:amp` - Alternative to velocity (0.0-1.0 → 0-127)
  - `:channel` - MIDI channel (1-16), default: 1
  - `:duration_ms` - Note duration in milliseconds (schedules note-off)
  - `:port` - MIDI port name (uses default if not specified)
  - `:cc` - Control change map, e.g., `%{1 => 64, 7 => 100}`
  - `:program` - Program change (0-127)

  ## Examples

      Waveform.MIDI.play(note: 60, velocity: 80)
      Waveform.MIDI.play(n: 64, gain: 0.8, channel: 2)
      Waveform.MIDI.play(note: 60, cc: %{1 => 64})

  """
  def play(params) when is_list(params) do
    play(Map.new(params))
  end

  def play(params) when is_map(params) do
    channel = get_channel(params)
    velocity = get_velocity(params)
    port_name = Map.get(params, :port)

    # Handle program change if present
    if program = Map.get(params, :program) do
      program_change(program, channel, port_name)
    end

    # Handle control changes if present
    if cc_map = Map.get(params, :cc) do
      Enum.each(cc_map, fn {cc_num, value} ->
        control_change(cc_num, value, channel, port_name)
      end)
    end

    # Handle note if present
    case get_note(params) do
      nil ->
        # CC-only or program-only event
        :ok

      note ->
        note_on(note, velocity, channel, port_name)

        # Schedule note-off if duration specified
        if duration_ms = Map.get(params, :duration_ms) do
          Scheduler.schedule_note_off(note, channel, duration_ms, port_name)
        end

        :ok
    end
  end

  @doc """
  Send all notes off (MIDI panic).

  Immediately sends note-off for all pending notes and clears the schedule.
  """
  def all_notes_off do
    Scheduler.all_notes_off()
  end

  @doc """
  Sends a MIDI Note On message.

  ## Parameters

  - `note` - MIDI note number (0-127)
  - `velocity` - MIDI velocity (0-127)
  - `channel` - MIDI channel (1-16)
  - `port_name` - Optional port name (uses default if nil)

  ## Examples

      Waveform.MIDI.note_on(60, 100, 1)
      Waveform.MIDI.note_on(64, 80, 2, "IAC Driver Bus 1")

  """
  def note_on(note, velocity, channel, port_name \\ nil) do
    send_message(note_on_msg(note, velocity, channel), port_name)
  end

  @doc """
  Sends a MIDI Note Off message.

  ## Parameters

  - `note` - MIDI note number (0-127)
  - `channel` - MIDI channel (1-16)
  - `port_name` - Optional port name (uses default if nil)

  ## Examples

      Waveform.MIDI.note_off(60, 1)
      Waveform.MIDI.note_off(64, 2, "IAC Driver Bus 1")

  """
  def note_off(note, channel, port_name \\ nil) do
    send_message(note_off_msg(note, channel), port_name)
  end

  @doc """
  Sends a MIDI Control Change message.

  ## Parameters

  - `cc_number` - Controller number (0-127)
  - `value` - Controller value (0-127)
  - `channel` - MIDI channel (1-16)
  - `port_name` - Optional port name (uses default if nil)

  ## Examples

      # Modulation wheel
      Waveform.MIDI.control_change(1, 64, 1)

      # Volume
      Waveform.MIDI.control_change(7, 100, 1)

  """
  def control_change(cc_number, value, channel, port_name \\ nil) do
    send_message(cc_msg(cc_number, value, channel), port_name)
  end

  @doc """
  Sends a MIDI Program Change message.

  ## Parameters

  - `program` - Program number (0-127)
  - `channel` - MIDI channel (1-16)
  - `port_name` - Optional port name (uses default if nil)

  ## Examples

      Waveform.MIDI.program_change(5, 1)

  """
  def program_change(program, channel, port_name \\ nil) do
    send_message(program_change_msg(program, channel), port_name)
  end

  # Message builders

  @doc false
  def note_on_msg(note, velocity, channel) do
    <<@note_on + (channel - 1), clamp_midi(note), clamp_midi(velocity)>>
  end

  @doc false
  def note_off_msg(note, channel) do
    <<@note_off + (channel - 1), clamp_midi(note), 0>>
  end

  @doc false
  def cc_msg(cc_number, value, channel) do
    <<@control_change + (channel - 1), clamp_midi(cc_number), clamp_midi(value)>>
  end

  @doc false
  def program_change_msg(program, channel) do
    <<@program_change + (channel - 1), clamp_midi(program)>>
  end

  # Private helpers

  defp send_message(msg, port_name) do
    case get_connection(port_name) do
      {:ok, conn} ->
        Midiex.send_msg(conn, msg)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_connection(nil) do
    Port.get_default_output()
  end

  defp get_connection(port_name_or_alias) do
    # Port.get_output handles both strings and alias atoms
    Port.get_output(port_name_or_alias)
  end

  defp get_note(params) do
    cond do
      note = Map.get(params, :note) -> note
      n = Map.get(params, :n) -> n
      true -> nil
    end
  end

  defp get_velocity(params) do
    default = Application.get_env(:waveform, :midi_default_velocity, 100)

    cond do
      velocity = Map.get(params, :velocity) ->
        clamp_midi(velocity)

      gain = Map.get(params, :gain) ->
        gain_to_velocity(gain)

      amp = Map.get(params, :amp) ->
        gain_to_velocity(amp)

      true ->
        default
    end
  end

  defp get_channel(params) do
    default = Application.get_env(:waveform, :midi_default_channel, 1)
    channel = Map.get(params, :channel, default)
    # Clamp to 1-16
    max(1, min(16, channel))
  end

  defp gain_to_velocity(gain) when is_number(gain) do
    curve = Application.get_env(:waveform, :midi_velocity_curve, :linear)
    apply_velocity_curve(gain, curve) |> clamp_midi()
  end

  # Velocity curve implementations
  # Linear: direct mapping, gain 0.5 → velocity ~64
  defp apply_velocity_curve(gain, :linear) do
    round(gain * 127)
  end

  # Exponential: more musical feel, quiet values stay quieter
  # Uses x^2 curve: gain 0.5 → velocity ~32
  defp apply_velocity_curve(gain, :exponential) do
    round(:math.pow(gain, 2) * 127)
  end

  # Custom curve with configurable exponent
  # :logarithmic uses sqrt (x^0.5): quiet values are louder
  defp apply_velocity_curve(gain, :logarithmic) do
    round(:math.sqrt(gain) * 127)
  end

  defp clamp_midi(value) when is_number(value) do
    value |> round() |> max(0) |> min(127)
  end
end
