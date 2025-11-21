defmodule Waveform.OSC.GroupTest do
  use ExUnit.Case, async: true

  alias Waveform.OSC.Group
  alias Waveform.OSC.Node

  setup do
    # Start Node.ID with unique initial value for isolation
    initial_id = :rand.uniform(1000) * 100
    node_id = start_supervised!({Node.ID, [name: nil, initial_id: initial_id]})

    # Start Group GenServer
    group = start_supervised!({Group, [name: nil, node_id_server: node_id]})

    %{group: group, node_id: node_id}
  end

  test "setup creates root synth group", %{group: group} do
    # Call setup to create root synth group
    assert :ok = Group.setup(group)

    # Verify root synth group was created
    state = Group.state(group)
    assert %Group{name: :root_synth_group, type: :synth} = state.root_synth_group
  end

  test "creates custom group", %{group: group} do
    # Setup root synth group first
    Group.setup(group)
    state_before = Group.state(group)
    root_synth_group = state_before.root_synth_group

    # Create a custom group
    assert %Group{
             type: :custom,
             name: :foo,
             parent: ^root_synth_group
           } = GenServer.call(group, {:new_group, :foo, :custom, :head, root_synth_group})
  end

  test "set and get process group", %{group: group} do
    # Setup root synth group
    Group.setup(group)
    state = Group.state(group)
    root_synth_group = state.root_synth_group

    # Create a custom group
    foo_group = GenServer.call(group, {:new_group, :foo, :custom, :head, root_synth_group})

    # Set process group
    test_pid = self()
    assert :ok = Group.set_process_group(test_pid, foo_group, group)

    # Verify it was set
    process_state = Group.state(group)
    assert process_state.process_groups[test_pid] == foo_group
  end

  test "cleans up process groups on process death", %{group: group} do
    # Setup root synth group
    Group.setup(group)
    state = Group.state(group)
    root_synth_group = state.root_synth_group

    # Create a custom group
    foo_group = GenServer.call(group, {:new_group, :foo, :custom, :head, root_synth_group})

    # Create a task that will exit
    task =
      Task.async(fn ->
        receive do
          :exit -> :ok
        end
      end)

    task_pid = task.pid

    # Set group for the task
    Group.set_process_group(task_pid, foo_group, group)

    # Verify it was set
    state_before = Group.state(group)
    assert Map.has_key?(state_before.process_groups, task_pid)

    # Kill the task
    send(task_pid, :exit)
    Task.await(task)

    # Give the DOWN message time to be processed
    Process.sleep(50)

    # Verify the process group was cleaned up
    state_after = Group.state(group)
    refute Map.has_key?(state_after.process_groups, task_pid)
  end

  test "creates nested groups", %{group: group} do
    # Setup root synth group
    Group.setup(group)
    state = Group.state(group)
    root_synth_group = state.root_synth_group

    # Create first group under root
    foo_group = GenServer.call(group, {:new_group, :foo, :custom, :head, root_synth_group})
    assert %Group{parent: ^root_synth_group, name: :foo} = foo_group

    # Set it as current for this process
    Group.set_process_group(self(), foo_group, group)

    # Create second group - should be under foo since it's the current group
    bar_group = GenServer.call(group, {:new_group, :bar, :custom, :head, foo_group})
    assert %Group{parent: ^foo_group, name: :bar} = bar_group

    # Can also explicitly specify parent
    baz_group = GenServer.call(group, {:new_group, :baz, :custom, :head, root_synth_group})
    assert %Group{parent: ^root_synth_group, name: :baz} = baz_group
  end
end
