defmodule Waveform.OSC.GroupTest do
  use ExUnit.Case, async: false

  alias Waveform.OSC.Group, as: Subject

  alias Subject, as: Group

  alias Waveform.OSC
  alias Waveform.OSC.Node.ID

  setup do
    # Ensure GenServers are running, restart if needed
    # Check and start Node.ID
    case Process.whereis(ID) do
      nil ->
        {:ok, _} = ID.start_link(100)

      pid ->
        # Check if it's alive
        if Process.alive?(pid) do
          :ok
        else
          # Dead process still registered, unregister and start new one
          Process.unregister(ID)
          {:ok, _} = ID.start_link(100)
        end
    end

    # Check and start Group
    case Process.whereis(Group) do
      nil ->
        {:ok, _} = Group.start_link(nil)

      pid ->
        if Process.alive?(pid) do
          :ok
        else
          Process.unregister(Group)
          {:ok, _} = Group.start_link(nil)
        end
    end

    Subject.reset()

    :ok
  end

  test "setup" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      assert :ok = Subject.setup()

      assert called(OSC.new_group(ID.state().current_id, :head, 1))

      assert Subject.synth_group(self()) == Subject.state().root_synth_group
    end
  end

  test "creates custom group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()

      root_synth_group = Subject.state().root_synth_group

      parent = %Group{id: ID.next()}

      next_id = parent.id + 1

      assert %Group{
               id: ^next_id,
               type: :custom,
               name: :foo,
               parent: ^root_synth_group
             } = Subject.new_group(:foo)

      assert called(OSC.new_group(ID.state().current_id, :head, root_synth_group.id))
    end
  end

  test "sets process group and cleans up on process death" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      # Ensure Group is alive before calling setup
      unless Process.alive?(Process.whereis(Group)) do
        {:ok, _} = Group.start_link(nil)
      end

      Subject.setup()

      # Create two processes that wait for messages before exiting
      task1 =
        Task.async(fn ->
          receive do
            :exit -> :ok
          end
        end)

      task2 =
        Task.async(fn ->
          receive do
            :exit -> :ok
          end
        end)

      pid = task1.pid
      pid2 = task2.pid

      assert %Group{} = foo = Subject.new_group(:foo)
      assert %Group{} = bar = Subject.new_group(:bar)

      assert :ok = Subject.set_process_group(pid, foo)
      assert ^foo = Subject.synth_group(pid)

      assert :ok = Subject.set_process_group(pid2, bar)
      assert ^bar = Subject.synth_group(pid2)

      # Now signal the tasks to exit
      send(pid, :exit)
      send(pid2, :exit)

      # Wait for tasks to complete
      Task.await(task1)
      Task.await(task2)

      # Give the DOWN message time to be processed
      Process.sleep(50)

      # Verify that dead processes were cleaned up
      state = Subject.state()
      refute Map.has_key?(state.process_groups, pid)
      refute Map.has_key?(state.process_groups, pid2)
    end
  end

  test "creates nested groups" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()
      root_synth_group = Subject.state().root_synth_group

      assert %Group{} = foo = Subject.new_group(:foo)

      assert %Group{
               parent: ^root_synth_group,
               name: :bar,
               type: :custom
             } = cg1 = Subject.new_group(:bar)

      assert called(OSC.new_group(foo.id + 1, :head, root_synth_group.id))
      assert :ok = Subject.set_process_group(self(), foo)

      assert ^foo = Subject.synth_group(self())

      assert %Group{
               parent: ^foo
             } = Subject.new_group(:bar)

      assert called(OSC.new_group(cg1.id + 1, :head, foo.id))

      assert %Group{
               parent: ^root_synth_group
             } = Subject.new_group(:bar, root_synth_group)
    end
  end
end
