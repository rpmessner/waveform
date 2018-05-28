defmodule Waveform.OSC.Node.ID do
  use GenServer

  @me __MODULE__

  defmodule State do
    defstruct(
      current_id: 0,
    )
  end

  def next do
    GenServer.call(@me, {:next})
  end

  def start_link(initial_id \\ 0) do
    GenServer.start_link(@me, %State{current_id: initial_id}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:next}, _from, state) do
    state = %{state | current_id: state.current_id + 1}
    {:reply, state.current_id, state}
  end
end
