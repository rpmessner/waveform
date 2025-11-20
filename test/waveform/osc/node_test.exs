defmodule Waveform.OSC.NodeTest do
  use ExUnit.Case, async: true

  alias Waveform.OSC.Node

  describe "node lifecycle tracking" do
    setup do
      # Start Node GenServer with unique name
      name = :"node_#{:rand.uniform(1_000_000)}"
      {:ok, pid} = GenServer.start(Node, %Node.State{}, name: name)

      on_exit(fn ->
        if Process.alive?(pid), do: GenServer.stop(pid)
      end)

      %{node_pid: pid}
    end

    test "next_synth_node creates inactive node", %{node_pid: pid} do
      node = GenServer.call(pid, {:next_node, %Node{type: :synth, id: 100}})

      assert %Node{type: :synth, id: 100, active: false} = node
      assert is_integer(node.created_at)

      # Check it's in inactive_nodes
      state = :sys.get_state(pid)
      assert Map.has_key?(state.inactive_nodes, 100)
    end

    test "next_fx_node creates inactive fx node", %{node_pid: pid} do
      node = GenServer.call(pid, {:next_node, %Node{type: :fx, id: 200}})

      assert %Node{type: :fx, id: 200, active: false} = node
    end

    test "activate_node moves node from inactive to active", %{node_pid: pid} do
      # Create node
      GenServer.call(pid, {:next_node, %Node{type: :synth, id: 100}})

      # Activate it
      GenServer.cast(pid, {:activate_node, 100})
      Process.sleep(10)  # Give cast time to process

      # Check state
      state = :sys.get_state(pid)
      refute Map.has_key?(state.inactive_nodes, 100)
      assert Map.has_key?(state.active_nodes, 100)
      assert state.active_nodes[100].active == true
    end

    test "deactivate_node moves node from active to dead", %{node_pid: pid} do
      # Create and activate node
      GenServer.call(pid, {:next_node, %Node{type: :synth, id: 100}})
      GenServer.cast(pid, {:activate_node, 100})
      Process.sleep(10)

      # Deactivate it
      GenServer.cast(pid, {:deactivate_node, 100})
      Process.sleep(10)

      # Check state
      state = :sys.get_state(pid)
      refute Map.has_key?(state.active_nodes, 100)
      assert Map.has_key?(state.dead_nodes, 100)
      assert state.dead_nodes[100].active == false
    end

    test "activate_node on non-existent node is ignored", %{node_pid: pid} do
      # Should not crash
      GenServer.cast(pid, {:activate_node, 999})
      Process.sleep(10)

      state = :sys.get_state(pid)
      refute Map.has_key?(state.active_nodes, 999)
    end

    test "deactivate_node on non-existent node is ignored", %{node_pid: pid} do
      # Should not crash
      GenServer.cast(pid, {:deactivate_node, 999})
      Process.sleep(10)

      state = :sys.get_state(pid)
      refute Map.has_key?(state.dead_nodes, 999)
    end
  end

  describe "node pruning" do
    test "old dead nodes are pruned after timeout" do
      # Start Node process with unique name
      name = :"node_pruning_#{:rand.uniform(1_000_000)}"
      {:ok, pid} = GenServer.start(Node, %Node.State{}, name: name)

      # Create and kill a node
      GenServer.call(pid, {:next_node, %Node{type: :synth, id: 100}})
      GenServer.cast(pid, {:activate_node, 100})
      Process.sleep(10)
      GenServer.cast(pid, {:deactivate_node, 100})
      Process.sleep(10)

      # Node should be in dead_nodes
      state_before = :sys.get_state(pid)
      assert Map.has_key?(state_before.dead_nodes, 100)

      # Manually set created_at to old timestamp
      old_timestamp = System.monotonic_time(:millisecond) - 120_000  # 2 minutes ago
      state_with_old = %{
        state_before
        | dead_nodes: Map.update!(state_before.dead_nodes, 100, fn node ->
            %{node | created_at: old_timestamp}
          end)
      }
      :sys.replace_state(pid, fn _ -> state_with_old end)

      # Trigger prune by sending the message
      send(pid, :prune_dead_nodes)
      Process.sleep(50)

      # Old node should be pruned
      state_after = :sys.get_state(pid)
      refute Map.has_key?(state_after.dead_nodes, 100)

      GenServer.stop(pid)
    end
  end
end
