defmodule Waveform.OSC.GroupTest do
  use ExUnit.Case, async: false
  import Mock

  alias Waveform.OSC.Group, as: Subject

  alias Subject, as: Group

  alias Waveform.OSC
  alias Waveform.OSC.Node.ID

  setup do
    # Start the application if not already started
    {:ok, _} = Application.ensure_all_started(:waveform)

    Subject.reset()

    on_exit(fn ->
      Subject.reset()
    end)

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

  test "activates synth group and cleans up on process death" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()

      # Create two short-lived processes
      task1 = Task.async(fn -> :ok end)
      task2 = Task.async(fn -> :ok end)

      pid = task1.pid
      pid2 = task2.pid

      assert %Group{} = foo = Subject.new_group(:foo)
      assert %Group{} = bar = Subject.new_group(:bar)

      assert :ok = Subject.activate_synth_group(pid, foo)
      assert ^foo = Subject.synth_group(pid)

      assert :ok = Subject.activate_synth_group(pid2, bar)
      assert ^bar = Subject.synth_group(pid2)

      # Wait for tasks to complete
      Task.await(task1)
      Task.await(task2)

      # Give the DOWN message time to be processed
      Process.sleep(50)

      # Verify that dead processes were cleaned up
      state = Subject.state()
      refute Map.has_key?(state.active_synth_group, pid)
      refute Map.has_key?(state.active_synth_group, pid2)
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
      assert :ok = Subject.activate_synth_group(self(), foo)

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
