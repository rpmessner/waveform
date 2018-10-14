defmodule Waveform.Synth.Def.Submodule do
  use GenServer

  @me __MODULE__
  alias __MODULE__

  defstruct(
    name: nil,
    params: [],
    forms: []
  )

  defmodule State do
    defstruct(submodules: %{})
  end

  def define(name, params, forms) do
    GenServer.call(@me, {:define, name, params, forms})
  end

  def lookup(name) do
    GenServer.call(@me, {:lookup, name})
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state(), name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:lookup, name}, _from, %State{}=state) do
    submodule = Map.get(state.submodules, name)

    {:reply, submodule, state}
  end

  def handle_call({:define, name, params, forms}, _from, %State{}=state) do
    submodule = %Submodule{name: name, params: params, forms: forms}
    state = %{state | submodules: Map.put(state.submodules, name, submodule)}

    {:reply, submodule, state }
  end

  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, default_state()}
  end

  defp default_state do
    %State{}
  end
end
