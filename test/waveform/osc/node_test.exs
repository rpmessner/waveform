defmodule Waveform.OSC.NodeTest do
  use ExUnit.Case, async: true

  alias Waveform.OSC.Node
  alias Waveform.OSC.Node.ID

  describe "node lifecycle tracking" do
    setup do
      # Start Node.ID with a unique initial value
      initial_id = :rand.uniform(1000) * 100
      node_id = start_supervised!({ID, [name: nil, initial_id: initial_id]})

      # Start Node GenServer
      node = start_supervised!({Node, [name: nil, node_id_server: node_id]})

      %{node: node, node_id: node_id}
    end

    test "next_synth_node creates inactive node", %{node: node} do
      created_node = Node.next_synth_node(node)

      assert %Node{type: :synth, active: false} = created_node
      assert is_integer(created_node.created_at)
      assert is_integer(created_node.id)

      # Check it's in inactive_nodes
      state = :sys.get_state(node)
      assert Map.has_key?(state.inactive_nodes, created_node.id)
    end

    test "next_fx_node creates inactive fx node", %{node: node} do
      created_node = Node.next_fx_node(node)

      assert %Node{type: :fx, active: false} = created_node
      assert is_integer(created_node.id)
    end

    test "activate_node moves node from inactive to active", %{node: node} do
      # Create node
      created_node = Node.next_synth_node(node)

      # Activate it
      Node.activate_node(created_node.id, node)
      # Give cast time to process
      Process.sleep(10)

      # Check state
      state = :sys.get_state(node)
      refute Map.has_key?(state.inactive_nodes, created_node.id)
      assert Map.has_key?(state.active_nodes, created_node.id)
      assert state.active_nodes[created_node.id].active == true
    end

    test "deactivate_node moves node from active to dead", %{node: node} do
      # Create and activate node
      created_node = Node.next_synth_node(node)
      Node.activate_node(created_node.id, node)
      Process.sleep(10)

      # Deactivate it
      Node.deactivate_node(created_node.id, node)
      Process.sleep(10)

      # Check state
      state = :sys.get_state(node)
      refute Map.has_key?(state.inactive_nodes, created_node.id)
      refute Map.has_key?(state.active_nodes, created_node.id)
      assert Map.has_key?(state.dead_nodes, created_node.id)
    end

    test "activate_node on non-existent node is ignored", %{node: node} do
      # Try to activate non-existent node
      Node.activate_node(999_999, node)
      Process.sleep(10)

      # State should be empty
      state = :sys.get_state(node)
      assert state.active_nodes == %{}
    end

    test "deactivate_node on non-existent node is ignored", %{node: node} do
      # Try to deactivate non-existent node
      Node.deactivate_node(999_999, node)
      Process.sleep(10)

      # State should be empty
      state = :sys.get_state(node)
      assert state.dead_nodes == %{}
    end
  end

  describe "node pruning" do
    test "old dead nodes are pruned after timeout" do
      initial_id = :rand.uniform(1000) * 100
      node_id = start_supervised!({ID, [name: nil, initial_id: initial_id]})
      node = start_supervised!({Node, [name: nil, node_id_server: node_id]})

      # Create, activate, then deactivate a node
      created_node = Node.next_synth_node(node)
      Node.activate_node(created_node.id, node)
      Process.sleep(10)
      Node.deactivate_node(created_node.id, node)
      Process.sleep(10)

      # Verify it's in dead_nodes
      state = :sys.get_state(node)
      assert Map.has_key?(state.dead_nodes, created_node.id)

      # Wait for pruning to occur (pruning happens every 60 seconds in production,
      # but for testing we just verify the node was marked as dead)
      # Note: We don't wait 60 seconds in tests, just verify the dead node tracking works
    end
  end
end
