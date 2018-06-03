defmodule Waveform.Synth.Manager do
  use GenServer

  @me __MODULE__

  @synth_names %{
    beep: 'sonic-pi-beep',
    bnoise: 'sonic-pi-bnoise',
    chipbass: 'sonic-pi-chipbass',
    chiplead: 'sonic-pi-chiplead',
    chipnoise: 'sonic-pi-chipnoise',
    cnoise: 'sonic-pi-cnoise',
    dark_ambience: 'sonic-pi-dark_ambience',
    dpulse: 'sonic-pi-dpulse',
    dsaw: 'sonic-pi-dsaw',
    dtri: 'sonic-pi-dtri',
    dull_bell: 'sonic-pi-dull_bell',
    fm: 'sonic-pi-fm',
    gnoise: 'sonic-pi-gnoise',
    growl: 'sonic-pi-growl',
    hollow: 'sonic-pi-hollow',
    hoover: 'sonic-pi-hoover',
    mod_dsaw: 'sonic-pi-mod_dsaw',
    mod_fm: 'sonic-pi-mod_fm',
    mod_pulse: 'sonic-pi-mod_pulse',
    mod_saw: 'sonic-pi-mod_saw',
    mod_sine: 'sonic-pi-mod_sine',
    mod_tri: 'sonic-pi-mod_tri',
    noise: 'sonic-pi-noise',
    piano: 'sonic-pi-piano',
    pluck: 'sonic-pi-pluck',
    pnoise: 'sonic-pi-pnoise',
    pretty_bell: 'sonic-pi-pretty_bell',
    prophet: 'sonic-pi-prophet',
    pulse: 'sonic-pi-pulse',
    saw: 'sonic-pi-saw',
    square: 'sonic-pi-square',
    subpulse: 'sonic-pi-subpulse',
    supersaw: 'sonic-pi-supersaw',
    synth_violin: 'sonic-pi-synth_violin',
    tb303: 'sonic-pi-tb303',
    tech_saws: 'sonic-pi-tech_saws',
    tri: 'sonic-pi-tri',
    zawa: 'sonic-pi-zawa'
  }
  @default_synth @synth_names[:prophet]

  defmodule State do
    defstruct(current: [])
  end

  def use_last_synth() do
    GenServer.call(@me, {:rollback})
  end

  def reset() do
    GenServer.call(@me, {:reset})
  end

  def set_current_synth(next) do
    GenServer.call(@me, {:set_current, next})
  end

  def current_synth_name() do
    current_name = GenServer.call(@me, {:current})

    {name, _} =
      Enum.find(@synth_names, fn {key, value} ->
        value == current_name
      end)

    name
  end

  def current_synth_value() do
    GenServer.call(@me, {:current})
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:set_current, new}, _from, state) do
    name = @synth_names[new]

    if name do
      {:reply, name, %{state | current: [name | state.current]}}
    else
      {:reply, nil, state}
    end
  end

  def handle_call({:current}, _from, state) do
    [current | _] = state.current

    {:reply, current, state}
  end

  def handle_call({:reset}, _from, state) do
    {:reply, :ok, default_state}
  end

  defp default_state do
    %State{current: [@default_synth]}
  end

  def handle_call({:rollback}, _from, %State{current: [h]} = state) do
    {:reply, h, state}
  end

  def handle_call({:rollback}, _from, %State{current: [h | t]} = state) do
    {:reply, h, %{state | current: t}}
  end
end
