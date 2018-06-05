defmodule Waveform.OSC.GroupTest do
  use ExUnit.Case
  import Mock

  alias Waveform.OSC.Group, as: Subject

  alias Subject, as: Group

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Node.ID, as: ID

  setup do
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

      assert Subject.synth_group() == Subject.state().root_synth_group
    end
  end

  test "creates fx container group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      parent = %Group{id: ID.next()}

      next_id = parent.id + 1

      assert %Group{
               id: ^next_id,
               type: :fx_container_group,
               name: :reverb,
               parent: ^parent
             } = g = Subject.fx_container_group(:reverb, parent)

      assert called(OSC.new_group(ID.state().current_id, :tail, parent.id))
    end
  end

  test "creates fx synth group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      parent = %Group{id: ID.next()}

      next_id = parent.id + 1

      assert %Group{
               id: ^next_id,
               type: :fx_synth_group,
               name: :reverb,
               parent: ^parent
             } = g = Subject.fx_synth_group(:reverb, parent)

      assert called(OSC.new_group(ID.state().current_id, :head, parent.id))
    end
  end

  test "creates track container group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()

      root_synth_group = Subject.state().root_synth_group

      parent = %Group{id: ID.next()}

      next_id = parent.id + 1

      assert %Group{
               id: ^next_id,
               type: :track_container_group,
               name: :foo,
               parent: ^root_synth_group
             } = g = Subject.track_container_group(:foo)

      assert called(OSC.new_group(ID.state().current_id, :head, root_synth_group.id))
    end
  end

  test "activates synth group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()

      assert %Group{} = foo = Subject.track_container_group(:foo)
      assert %Group{} = bar = Subject.track_container_group(:bar)

      assert :ok = Subject.activate_synth_group(foo)

      assert ^foo = Subject.synth_group()

      assert :ok = Subject.activate_synth_group(bar)

      assert ^bar = Subject.synth_group()
    end
  end

  test "restore synth group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()
      root_synth_group = Subject.state().root_synth_group

      assert %Group{} = foo = Subject.track_container_group(:foo)
      assert %Group{} = bar = Subject.track_container_group(:bar)

      assert :ok = Subject.activate_synth_group(foo)

      assert ^foo = Subject.synth_group()

      assert :ok = Subject.activate_synth_group(bar)

      assert ^bar = Subject.synth_group()

      assert {:ok, ^foo} = Subject.restore_synth_group()
      assert {:ok, ^root_synth_group} = Subject.restore_synth_group()
      assert {:ok, nil} = Subject.restore_synth_group()
    end
  end

  test "creates chord group" do
    with_mock OSC, new_group: fn _, _, _ -> nil end do
      Subject.setup()
      root_synth_group = Subject.state().root_synth_group

      assert %Group{} = foo = Subject.track_container_group(:foo)

      assert %Group{
               parent: ^root_synth_group,
               name: :bar,
               type: :chord_group
             } = cg1 = Subject.chord_group(:bar)

      assert called(OSC.new_group(foo.id + 1, :head, root_synth_group.id))
      assert :ok = Subject.activate_synth_group(foo)

      assert ^foo = Subject.synth_group()

      assert %Group{
               parent: ^foo
             } = Subject.chord_group(:bar)

      assert called(OSC.new_group(cg1.id + 1, :head, foo.id))

      assert %Group{
               parent: ^root_synth_group
             } = Subject.chord_group(:bar, root_synth_group)
    end
  end
end
