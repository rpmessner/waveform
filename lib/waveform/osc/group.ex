defmodule Waveform.OSC.Group do
  use GenServer

  @me __MODULE__
  alias __MODULE__

  alias Waveform.AudioBus, as: AudioBus
  alias Waveform.OSC.Node.ID, as: ID
  alias Waveform.OSC, as: OSC

  defstruct(
    id: nil,
    name: nil,
    type: nil,
    children: [],
    nodes: [],
    out_bus: nil,
    in_bus: nil,
    parent: nil
  )

  defmodule State do
    defstruct(
      root_group: %Group{id: 1, name: :root},
      root_synth_group: nil,
      active_synth_group: []
    )
  end

  def reset do
    GenServer.call(@me, {:reset})
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def restore_synth_group() do
    GenServer.call(@me, {:restore_synth_group})
  end

  def activate_synth_group(%Group{id: id} = g) do
    GenServer.call(@me, {:activate_group, g})
  end

  def synth_group do
    state().active_synth_group |> List.first()
  end

  def setup do
    GenServer.call(@me, {:root_synth_group})
  end

  def chord_group(name) do
    GenServer.call(@me, {:new_group, name, :chord_group, :head, synth_group()})
  end

  def chord_group(name, parent_group) do
    GenServer.call(@me, {:new_group, name, :chord_group, :head, parent_group})
  end

  def fx_container_group(name, parent_group) do
    GenServer.call(
      @me,
      {:new_group, name, :fx_container_group, :tail, AudioBus.next(), parent_group}
    )
  end

  def fx_synth_group(name, container_group) do
    GenServer.call(@me, {:new_group, name, :fx_synth_group, :head, container_group})
  end

  def track_container_group(name) do
    GenServer.call(@me, {:new_group, name, :track_container_group, :head})
  end

  defp default_state do
    %State{}
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:restore_synth_group}, _from, %State{active_synth_group: [_]} = state) do
    {:reply, {:ok, nil}, state}
  end

  def handle_call({:restore_synth_group}, _from, %State{active_synth_group: [h | t]} = state) do
    {:reply, {:ok, List.first(t)}, %{state | active_synth_group: t}}
  end

  def handle_call({:root_synth_group}, _from, state) do
    group = %Group{type: :synth, name: :root_synth_group, id: ID.next()}

    create_group(group.id, :head, state.root_group.id)

    {:reply, :ok, %{state | active_synth_group: [group], root_synth_group: group}}
  end

  def handle_call({:activate_group, %Group{} = g}, _from, state) do
    {:reply, :ok, %{state | active_synth_group: [g | state.active_synth_group]}}
  end

  def handle_call({:new_group, name, type, action}, from, state) do
    handle_call({:new_group, name, type, action, state.root_synth_group}, from, state)
  end

  def handle_call(
        {:new_group, name, type, action, %Group{id: parent_id, out_bus: out_bus} = parent},
        _from,
        state
      ) do
    new_group = %Group{out_bus: out_bus, name: name, type: type, id: ID.next(), parent: parent}

    create_group(new_group.id, action, parent_id)

    {:reply, new_group, state}
  end

  def handle_call(
        {:new_group, name, type, action, out_bus, %Group{id: parent_id} = parent},
        _from,
        state
      ) do
    new_group = %Group{out_bus: out_bus, name: name, type: type, id: ID.next(), parent: parent}

    create_group(new_group.id, action, parent_id)

    {:reply, new_group, state}
  end

  defp create_group(id, action, parent) do
    OSC.new_group(id, action, parent)
  end

  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, default_state}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
end
