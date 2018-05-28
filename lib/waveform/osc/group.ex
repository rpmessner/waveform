defmodule Waveform.OSC.Group do
  use GenServer

  @me __MODULE__
  alias __MODULE__
  alias Waveform.OSC.Node.ID, as: ID
  alias Waveform.OSC, as: OSC

  defmodule State do
    defstruct(groups: [])
  end

  defstruct(id: nil, name: nil)

  def state do
    GenServer.call(@me, {:state})
  end

  def root_group do
    %Group{id: 0, name: "ROOT"}
  end

  def new_group do
    GenServer.call(@me, {:new_group, root_group()})
  end

  def new_group(%Group{} = parent) do
    GenServer.call(@me, {:new_group, parent})
  end

  def start_link(_state) do
    GenServer.start_link(@me, %State{groups: [root_group()]}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:new_group, parent}, _from, state) do
    new_group = %Group{id: ID.next()}
    OSC.send_command(['/g_new', new_group.id, 0, parent.id])
    {:reply, new_group, %{state | groups: [new_group | state.groups]}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
end
