defmodule Waveform.Synth.FxTest do
  use ExUnit.Case
  import Mock

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node.ID, as: ID
  alias Waveform.OSC.Node, as: Node
  alias Waveform.Synth.FX, as: Subject

  setup do
    Waveform.AudioBus.setup(100, 4)

    on_exit(fn ->
      Waveform.AudioBus.reset()
    end)
  end

  test "returns original when fx not found" do
    parent = %Group{id: ID.next()}
    assert ^parent = Subject.add_fx(parent, :wtf_is_this, amp: 1)
  end

  test "creates a fx group" do
    with_mock OSC,
      new_group: fn _, _, _ -> nil end,
      new_synth: fn _, _, _, _, _ -> nil end do
      parent = %Group{id: ID.next()}

      container_group_id = parent.id + 1
      synth_group_id = parent.id + 2
      synth_id = parent.id + 3

      assert %Group{
               id: ^container_group_id,
               parent: ^parent,
               out_bus: in_bus,
               nodes: [
                 %Node{id: ^synth_id}
               ],
               children: [
                 %Group{id: ^synth_group_id}
               ]
             } = Subject.add_fx(parent, :reverb, amp: 1)

      assert called(OSC.new_group(container_group_id, :tail, parent.id))
      assert called(OSC.new_group(synth_group_id, :head, container_group_id))

      assert called(
               OSC.new_synth('sonic-pi-fx_reverb', synth_id, :tail, container_group_id, [
                 :amp,
                 1,
                 :in_bus,
                 in_bus
               ])
             )
    end
  end

  test "creates a nested fx group" do
    with_mock OSC,
      new_group: fn _, _, _ -> nil end,
      new_synth: fn _, _, _, _, _ -> nil end do

      parent = %Group{id: ID.next()}

      container_group_id = parent.id + 1
      synth_group_id = parent.id + 2
      synth_id = parent.id + 3

      %Group{out_bus: in_bus} = fx_group = Subject.add_fx(parent, :reverb, amp: 1)

      container_group_id_2 = synth_id + 1
      synth_group_id_2 = synth_id + 2
      synth_id_2 = synth_id + 3
      in_bus_2 = in_bus + 2

      assert %Group{
               id: ^container_group_id_2,
               out_bus: ^in_bus_2,
               in_bus: ^in_bus,
               type: :fx_container_group,
               parent: ^fx_group,
               nodes: [
                 %Node{id: ^synth_id_2}
               ],
               children: [
                 %Group{id: ^synth_group_id_2}
               ]
             } = Subject.add_fx(fx_group, :wobble, phase: 2)

      assert called(
               OSC.new_synth('sonic-pi-fx_wobble', synth_id_2, :tail, container_group_id_2, [
                 :phase,
                 2,
                 :out_bus,
                 in_bus,
                 :in_bus,
                 in_bus_2
               ])
             )
    end
  end
end
