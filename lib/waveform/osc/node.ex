defmodule Waveform.OSC.Node do
  use GenServer

  @me __MODULE__
  alias __MODULE__
  alias Waveform.OSC.Node.ID, as: ID

  defmodule State do
    defstruct(
      # havn't recieved confirmation
      inactive_nodes: [],
      # alive in supercollider
      active_nodes: [],
      # dead in supercollider
      dead_nodes: []
    )
  end

  defstruct(
    id: nil,
    active: nil
  )

  def state do
    GenServer.call(@me, {:state})
  end

  def next_node do
    GenServer.call(@me, {:next_node})
  end

  def activate_node(node_id) do
    GenServer.cast(@me, {:activate_node, node_id})
  end

  def deactivate_node(node_id) do
    GenServer.cast(@me, {:deactivate_node, node_id})
  end

  def start_link(_state) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:deactivate_node, node_id}, state) do
    active_node = Enum.find(state.active_nodes, &(&1.id == node_id))

    if active_node do
      active_nodes = Enum.filter(state.active_nodes, &(&1.id != node_id))
      dead_nodes = [%{active_node | active: false} | state.dead_nodes]
      new_state = %{state | active_nodes: active_nodes, dead_nodes: dead_nodes}
      # IO.inspect({"removing_node:", state, active_node, new_state})
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:activate_node, node_id}, state) do
    inactive_node = Enum.find(state.inactive_nodes, &(&1.id == node_id))

    if inactive_node do
      inactive_nodes = Enum.filter(state.inactive_nodes, &(&1.id != node_id))
      active_nodes = [%{inactive_node | active: true} | state.active_nodes]
      new_state = %{state | active_nodes: active_nodes, inactive_nodes: inactive_nodes}
      # IO.inspect({"removing node:", state, inactive_node, new_state})
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_call({:next_node}, _from, state) do
    next = %Node{id: ID.next()}
    inactive_nodes = [next | state.inactive_nodes]
    {:reply, next, %{state | inactive_nodes: inactive_nodes}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
end
