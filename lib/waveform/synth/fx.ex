defmodule Waveform.Synth.FX do
  use GenServer

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node.ID, as: ID

  alias __MODULE__
  @me __MODULE__

  @enabled_fx %{
    reverb: 'sonic-pi-fx_reverb'
  }

  defstruct(
    container_group: nil,
    synth_group: nil,
    synth_node: nil
  )

  defmodule State do
    defstruct(effects: [])
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def new_fx(type, options) do
    if fx_name = @enabled_fx[type] do
      GenServer.call(@me, {:new_fx, type, fx_name, options})
    else
      {:error, "unknown fx name"}
    end
  end

  def start_link(_state) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_fx, type, name, options}, _from, state) do
    container_group = Group.fx_container_group(type)
    synth_group = Group.fx_synth_group(type, container_group)

    synth_node = OSC.new_synth(name, ID.next(), :tail, container_group.id, options)

    fx = %FX{synth_node: synth_node, container_group: container_group, synth_group: synth_group}

    {:reply, fx, %{state | effects: [fx | state.effects]}}
  end
end
