defmodule Waveform.OSC.Group do
  use GenServer

  @me __MODULE__
  alias __MODULE__
  alias Waveform.OSC.Node.ID, as: ID
  alias Waveform.OSC, as: OSC

  defstruct(id: nil, name: nil)

  defmodule State do
    defstruct(
      groups: [],
      root_group: %Group{id: 1, name: :root},
      synth_group: nil
    )
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def root_group do
    state.root_group
  end

  def synth_group do
    state.synth_group
  end

  def setup do
    GenServer.call(@me, {:synth_group})
  end

  def chord_group do
    GenServer.call(@me, {:new_group, :chord, :head, synth_group()})
  end

  @add_actions %{
    # add the new group to the the head of the group specified by the add target ID.
    head: 0,
    # add the new group to the the tail of the group specified by the add target ID.
    tail: 1,
    # add the new group just before the node specified by the add target ID.
    before: 2,
    # add the new group just after the node specified by the add target ID.
    after: 3,
    # the new node replaces the node specified by the add target ID. The target node is freed.
    replace: 4
  }

  def start_link(_state) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:synth_group}, _from, state) do
    group = %Group{name: :synth, id: ID.next()}
    create_group(group.id, :head, state.root_group.id)
    {:reply, group, %{state | synth_group: group}}
  end

  def handle_call({:new_group, name, action, parent}, _from, state) do
    new_group = %Group{name: name, id: ID.next()}
    create_group(new_group.id, @add_actions[action], parent.id)
    {:reply, new_group, %{state | groups: [new_group | state.groups]}}
  end

  defp create_group(id, action, parent) do
    OSC.send_command(['/g_new', id, action, parent])
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
end
