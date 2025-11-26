defmodule Waveform.MIDI.Scheduler do
  @moduledoc """
  Schedules delayed MIDI messages, primarily for note-off events.

  When a note is played with a duration, this GenServer schedules
  the corresponding note-off message to be sent after the specified time.
  """

  use GenServer

  @me __MODULE__

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(@me, opts, name: @me)
  end

  @doc """
  Schedule a note-off message to be sent after `delay_ms` milliseconds.

  ## Parameters

  - `note` - MIDI note number (0-127)
  - `channel` - MIDI channel (1-16)
  - `delay_ms` - Delay in milliseconds before sending note-off
  - `port_name` - Optional MIDI port name (uses default if nil)

  ## Examples

      Waveform.MIDI.Scheduler.schedule_note_off(60, 1, 500)
      Waveform.MIDI.Scheduler.schedule_note_off(64, 2, 1000, "IAC Driver Bus 1")

  """
  def schedule_note_off(note, channel, delay_ms, port_name \\ nil) do
    GenServer.cast(@me, {:schedule_note_off, note, channel, delay_ms, port_name})
  end

  @doc """
  Cancel all pending note-offs for a specific note/channel combination.

  Useful when a note is retriggered before its scheduled note-off.
  """
  def cancel_note_off(note, channel, port_name \\ nil) do
    GenServer.cast(@me, {:cancel_note_off, note, channel, port_name})
  end

  @doc """
  Send all pending note-offs immediately and clear the schedule.

  Useful for panic/hush functionality.
  """
  def all_notes_off do
    GenServer.cast(@me, :all_notes_off)
  end

  # Server Implementation

  @impl true
  def init(_opts) do
    # State is a map of {note, channel, port_name} -> timer_ref
    {:ok, %{pending: %{}}}
  end

  @impl true
  def handle_cast({:schedule_note_off, note, channel, delay_ms, port_name}, state) do
    key = {note, channel, port_name}

    # Cancel existing timer for this note if any (prevents duplicate note-offs)
    state = cancel_existing_timer(state, key)

    # Schedule new note-off
    timer_ref = Process.send_after(self(), {:send_note_off, key}, delay_ms)
    new_pending = Map.put(state.pending, key, timer_ref)

    {:noreply, %{state | pending: new_pending}}
  end

  @impl true
  def handle_cast({:cancel_note_off, note, channel, port_name}, state) do
    key = {note, channel, port_name}
    {:noreply, cancel_existing_timer(state, key)}
  end

  @impl true
  def handle_cast(:all_notes_off, state) do
    # Cancel all timers
    Enum.each(state.pending, fn {_key, timer_ref} ->
      Process.cancel_timer(timer_ref)
    end)

    # Send note-off for all pending notes
    Enum.each(state.pending, fn {{note, channel, port_name}, _timer_ref} ->
      Waveform.MIDI.note_off(note, channel, port_name)
    end)

    {:noreply, %{state | pending: %{}}}
  end

  @impl true
  def handle_info({:send_note_off, {note, channel, port_name} = key}, state) do
    # Send the note-off
    Waveform.MIDI.note_off(note, channel, port_name)

    # Remove from pending
    new_pending = Map.delete(state.pending, key)
    {:noreply, %{state | pending: new_pending}}
  end

  # Private helpers

  defp cancel_existing_timer(state, key) do
    case Map.get(state.pending, key) do
      nil ->
        state

      timer_ref ->
        Process.cancel_timer(timer_ref)
        %{state | pending: Map.delete(state.pending, key)}
    end
  end
end
