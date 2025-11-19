defmodule Waveform.OSC.Node do
  @moduledoc """
  Manages node allocation for SuperCollider synths.

  This module provides node allocation with basic lifecycle tracking.
  Nodes are pruned periodically to prevent unbounded memory growth.

  SuperCollider itself is the source of truth for node state - this module
  just provides lightweight tracking for debugging and monitoring purposes.
  """
  alias Waveform.OSC.Node.ID

  @me __MODULE__
  alias __MODULE__

  use GenServer

  # Prune dead nodes older than 60 seconds
  @prune_interval_ms 60_000
  @max_dead_node_age_ms 60_000

  defmodule State do
    @moduledoc false
    defstruct(
      # Nodes waiting for SuperCollider confirmation
      inactive_nodes: %{},
      # Nodes confirmed alive in SuperCollider
      active_nodes: %{},
      # Recently dead nodes (with timestamp for pruning)
      dead_nodes: %{}
    )
  end

  defstruct(
    type: nil,
    id: nil,
    out_bus: nil,
    in_bus: nil,
    active: false,
    created_at: nil
  )

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
    # Schedule periodic pruning of old dead nodes
    schedule_prune()
    {:ok, state}
  end

  def next_fx_node do
    GenServer.call(@me, {:next_node, %Node{type: :fx, id: ID.next()}})
  end

  def next_synth_node do
    GenServer.call(@me, {:next_node, %Node{type: :synth, id: ID.next()}})
  end

  def handle_cast({:deactivate_node, node_id}, state) do
    case Map.pop(state.active_nodes, node_id) do
      {nil, _} ->
        # Not in active nodes, ignore
        {:noreply, state}

      {node, active_nodes} ->
        # Move to dead nodes with timestamp
        dead_node = %{node | active: false, created_at: System.monotonic_time(:millisecond)}
        dead_nodes = Map.put(state.dead_nodes, node_id, dead_node)
        {:noreply, %{state | active_nodes: active_nodes, dead_nodes: dead_nodes}}
    end
  end

  def handle_cast({:activate_node, node_id}, state) do
    case Map.pop(state.inactive_nodes, node_id) do
      {nil, _} ->
        # Not in inactive nodes, ignore
        {:noreply, state}

      {node, inactive_nodes} ->
        # Move to active nodes
        active_node = %{node | active: true}
        active_nodes = Map.put(state.active_nodes, node_id, active_node)
        {:noreply, %{state | inactive_nodes: inactive_nodes, active_nodes: active_nodes}}
    end
  end

  def handle_call({:next_node, next}, _from, state) do
    node = %{next | created_at: System.monotonic_time(:millisecond)}
    inactive_nodes = Map.put(state.inactive_nodes, node.id, node)
    {:reply, next, %{state | inactive_nodes: inactive_nodes}}
  end

  def handle_info(:prune_dead_nodes, state) do
    now = System.monotonic_time(:millisecond)
    cutoff = now - @max_dead_node_age_ms

    # Keep only recent dead nodes
    dead_nodes =
      state.dead_nodes
      |> Enum.filter(fn {_id, node} -> node.created_at > cutoff end)
      |> Enum.into(%{})

    schedule_prune()
    {:noreply, %{state | dead_nodes: dead_nodes}}
  end

  defp schedule_prune do
    Process.send_after(self(), :prune_dead_nodes, @prune_interval_ms)
  end
end
