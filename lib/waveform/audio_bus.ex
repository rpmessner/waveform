defmodule Waveform.AudioBus do
  @moduledoc """
  Manages audio bus allocation for SuperCollider.

  Audio buses are used for routing audio between synths in SuperCollider.
  This module tracks available buses and allocates them on demand to avoid
  conflicts.

  The bus allocation is initialized based on server capabilities reported
  by SuperCollider during startup.
  """
  use GenServer

  @me __MODULE__
  @allocation_size 2

  defmodule State do
    defstruct(idx: 0, max_id: 1000, idx_offset: 4)
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state(), name: @me)
  end

  defp default_state do
    %State{}
  end

  def reset() do
    GenServer.call(@me, {:reset})
  end

  def init(state) do
    {:ok, state}
  end

  def peek() do
    GenServer.call(@me, {:peek})
  end

  def next() do
    GenServer.call(@me, {:next})
  end

  def setup(num_audio_busses, num_allocated_busses) do
    GenServer.cast(@me, {:setup, num_audio_busses, num_allocated_busses})
  end

  def handle_call({:peek}, _from, state) do
    {:reply, state.idx, state}
  end

  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, default_state()}
  end

  def handle_call({:next}, _from, %State{idx: idx, idx_offset: offset} = state) do
    {:reply, idx * @allocation_size + offset, %{state | idx: idx + 1}}
  end

  def handle_cast({:setup, num_audio_busses, num_allocated_busses}, state) do
    {:noreply,
     %{
       state
       | max_id: (num_audio_busses - num_allocated_busses) / @allocation_size - 1,
         idx_offset: num_allocated_busses
     }}
  end
end
