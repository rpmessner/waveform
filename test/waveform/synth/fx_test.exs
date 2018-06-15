defmodule Waveform.Synth.FxTest do
  use ExUnit.Case
  import Mock

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node.ID, as: ID
  alias Waveform.OSC.Node, as: Node
  alias Waveform.Synth.FX, as: Subject

  @bus_id 4

  setup do
    Waveform.AudioBus.setup(100, @bus_id)

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
      parent = %Group{id: ID.next(), type: :track_container_group}

      parent_id = parent.id
      fx_group_id = parent_id + 1
      synth_id = parent_id + 2
      bus_id = @bus_id

      assert %Group{
               id: ^parent_id,
               type: :track_container_group,
               in_bus: ^bus_id,
               children: [
                 %Group{type: :fx_container_group, id: ^fx_group_id}
               ],
               nodes: [
                 %Node{in_bus: ^bus_id, type: :fx, id: ^synth_id}
               ]
             } = Subject.add_fx(parent, :reverb, amp: 1)

      assert called(OSC.new_group(fx_group_id, :head, parent_id))

      assert called(
               OSC.new_synth('sonic-pi-fx_reverb', synth_id, :head, fx_group_id, [
                 :amp,
                 1,
                 :in_bus,
                 bus_id
               ])
             )
    end
  end

  test "creates a nested fx group" do
    with_mock OSC,
      new_group: fn _, _, _ -> nil end,
      new_synth: fn _, _, _, _, _ -> nil end do
      parent = %Group{id: ID.next(), type: :track_container_group}
      parent_id = parent.id

      fx_group_id = parent_id + 1
      synth_id = parent_id + 2
      synth_id_2 = parent_id + 3

      bus_id = @bus_id
      bus_id_2 = bus_id + 2

      parent =
        parent
        |> Subject.add_fx(:reverb, amp: 1)
        |> Subject.add_fx(:wobble, phase: 2)

      assert called(OSC.new_group(fx_group_id, :head, parent_id))

      assert %Group{
               id: ^parent_id,
               in_bus: ^bus_id_2,
               type: :track_container_group,
               children: [
                 %Group{type: :fx_container_group, id: ^fx_group_id}
               ],
               nodes: [
                 %Node{in_bus: ^bus_id_2, out_bus: ^bus_id, id: ^synth_id_2},
                 %Node{in_bus: ^bus_id, id: ^synth_id}
               ]
             } = parent

      assert called(
               OSC.new_synth('sonic-pi-fx_reverb', synth_id, :head, fx_group_id, [
                 :amp,
                 1,
                 :in_bus,
                 bus_id
               ])
             )

      assert called(
               OSC.new_synth('sonic-pi-fx_wobble', synth_id_2, :head, fx_group_id, [
                 :phase,
                 2,
                 :out_bus,
                 bus_id,
                 :in_bus,
                 bus_id_2
               ])
             )
    end
  end
end
