defmodule Waveform.Synth.Manager do
  use GenServer

  @me __MODULE__

  @synth_names %{
    prophet: 'sonic-pi-prophet',
    saw: 'sonic-pi-saw',
    dsaw: 'sonic-pi-dsaw',
    fm: 'sonic-pi-fm',
    pulse: 'sonic-pi-pulse',
    tb303: 'sonic-pi-tb303'
  }
  @default_synth @synth_names[:prophet]

  defmodule State do
    defstruct(current: nil)
  end

  def set_current_synth(next) do
    GenServer.call(@me, {:set_current, next})
  end

  def current_synth_atom() do
    current_name = GenServer.call(@me, {:current})

    {name, _} =
      Enum.find(@synth_names, fn {key, value} ->
        value == current_name
      end)

    name
  end

  def current_synth() do
    GenServer.call(@me, {:current})
  end

  def start_link(_state) do
    GenServer.start_link(@me, %State{current: @default_synth}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def terminate(_reason, _state), do: nil

  def handle_call({:set_current, new}, _from, state) do
    name = @synth_names[new]
    {:reply, if(name, do: new), %State{state | current: name || state.current}}
  end

  def handle_call({:current}, _from, state) do
    {:reply, state.current, state}
  end
end
