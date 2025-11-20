defmodule Waveform.OSC.GroupTest do
  use ExUnit.Case, async: true

  alias Waveform.OSC.Group

  setup do
    # Start Node.ID and Group GenServers with unique names for this test
    test_id = :rand.uniform(1_000_000)
    node_id_name = :"node_id_#{test_id}"
    group_name = :"group_#{test_id}"

    # Start with custom names using GenServer.start directly
    {:ok, node_id_pid} = GenServer.start(Waveform.OSC.Node.ID, %Waveform.OSC.Node.ID.State{current_id: 100}, name: node_id_name)
    {:ok, group_pid} = GenServer.start(Group, %Group.State{}, name: group_name)

    # Clean up after test
    on_exit(fn ->
      if Process.alive?(node_id_pid), do: GenServer.stop(node_id_pid)
      if Process.alive?(group_pid), do: GenServer.stop(group_pid)
    end)

    %{group_pid: group_pid, group_name: group_name}
  end

  test "setup creates root synth group", %{group_pid: pid} do
    # Call setup to create root synth group
    assert :ok = GenServer.call(pid, {:root_synth_group})

    # Verify root synth group was created
    state = GenServer.call(pid, {:state})
    assert %Group{name: :root_synth_group, type: :synth} = state.root_synth_group
  end

  test "creates custom group", %{group_pid: pid} do
    # Setup root synth group first
    GenServer.call(pid, {:root_synth_group})
    state_before = GenServer.call(pid, {:state})
    root_synth_group = state_before.root_synth_group

    # Create a custom group
    assert %Group{
             type: :custom,
             name: :foo,
             parent: ^root_synth_group
           } = GenServer.call(pid, {:new_group, :foo, :custom, :head, root_synth_group})
  end

  test "set and get process group", %{group_pid: pid} do
    # Setup root synth group
    GenServer.call(pid, {:root_synth_group})
    state = GenServer.call(pid, {:state})
    root_synth_group = state.root_synth_group

    # Create a custom group
    foo_group = GenServer.call(pid, {:new_group, :foo, :custom, :head, root_synth_group})

    # Set process group
    test_pid = self()
    assert :ok = GenServer.call(pid, {:set_process_group, test_pid, foo_group})

    # Verify it was set
    process_state = GenServer.call(pid, {:state})
    assert process_state.process_groups[test_pid] == foo_group
  end

  test "cleans up process groups on process death", %{group_pid: pid} do
    # Setup root synth group
    GenServer.call(pid, {:root_synth_group})
    state = GenServer.call(pid, {:state})
    root_synth_group = state.root_synth_group

    # Create a custom group
    foo_group = GenServer.call(pid, {:new_group, :foo, :custom, :head, root_synth_group})

    # Create a task that will exit
    task =
      Task.async(fn ->
        receive do
          :exit -> :ok
        end
      end)

    task_pid = task.pid

    # Set group for the task
    GenServer.call(pid, {:set_process_group, task_pid, foo_group})

    # Verify it was set
    state_before = GenServer.call(pid, {:state})
    assert Map.has_key?(state_before.process_groups, task_pid)

    # Kill the task
    send(task_pid, :exit)
    Task.await(task)

    # Give the DOWN message time to be processed
    Process.sleep(50)

    # Verify the process group was cleaned up
    state_after = GenServer.call(pid, {:state})
    refute Map.has_key?(state_after.process_groups, task_pid)
  end

  test "creates nested groups", %{group_pid: pid} do
    # Setup root synth group
    GenServer.call(pid, {:root_synth_group})
    state = GenServer.call(pid, {:state})
    root_synth_group = state.root_synth_group

    # Create first group under root
    foo_group = GenServer.call(pid, {:new_group, :foo, :custom, :head, root_synth_group})
    assert %Group{parent: ^root_synth_group, name: :foo} = foo_group

    # Set it as current for this process
    GenServer.call(pid, {:set_process_group, self(), foo_group})

    # Create second group - should be under foo since it's the current group
    bar_group = GenServer.call(pid, {:new_group, :bar, :custom, :head, foo_group})
    assert %Group{parent: ^foo_group, name: :bar} = bar_group

    # Can also explicitly specify parent
    baz_group = GenServer.call(pid, {:new_group, :baz, :custom, :head, root_synth_group})
    assert %Group{parent: ^root_synth_group, name: :baz} = baz_group
  end
end
