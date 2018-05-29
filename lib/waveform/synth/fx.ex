defmodule Waveform.Synth.FX do
  use GenServer

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Node, as: Node
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node.ID, as: ID

  alias __MODULE__
  @me __MODULE__

  @enabled_fx %{
    band_eq: 'sonic-pi-fx_band_eq',
    bitcrusher: 'sonic-pi-fx_bitcrusher',
    bpf: 'sonic-pi-fx_bpf',
    compressor: 'sonic-pi-fx_compressor',
    distortion: 'sonic-pi-fx_distortion',
    echo: 'sonic-pi-fx_echo',
    eq: 'sonic-pi-fx_eq',
    flanger: 'sonic-pi-fx_flanger',
    gverb: 'sonic-pi-fx_gverb',
    hpf: 'sonic-pi-fx_hpf',
    ixi_techno: 'sonic-pi-fx_ixi_techno',
    krush: 'sonic-pi-fx_krush',
    level: 'sonic-pi-fx_level',
    lpf: 'sonic-pi-fx_lpf',
    mono: 'sonic-pi-fx_mono',
    nbpf: 'sonic-pi-fx_nbpf',
    nhpf: 'sonic-pi-fx_nhpf',
    nlpf: 'sonic-pi-fx_nlpf',
    normaliser: 'sonic-pi-fx_normaliser',
    nrbpf: 'sonic-pi-fx_nrbpf',
    nrhpf: 'sonic-pi-fx_nrhpf',
    nrlpf: 'sonic-pi-fx_nrlpf',
    octaver: 'sonic-pi-fx_octaver',
    pan: 'sonic-pi-fx_pan',
    panslicer: 'sonic-pi-fx_panslicer',
    pitch_shift: 'sonic-pi-fx_pitch_shift',
    rbpf: 'sonic-pi-fx_rbpf',
    record: 'sonic-pi-fx_record',
    reverb: 'sonic-pi-fx_reverb',
    rhpf: 'sonic-pi-fx_rhpf',
    ring_mod: 'sonic-pi-fx_ring_mod',
    rlpf: 'sonic-pi-fx_rlpf',
    scope_out: 'sonic-pi-fx_scope_out',
    slicer: 'sonic-pi-fx_slicer',
    sound_out_stereo: 'sonic-pi-fx_sound_out_stereo',
    sound_out: 'sonic-pi-fx_sound_out',
    tanh: 'sonic-pi-fx_tanh',
    tremolo: 'sonic-pi-fx_tremolo',
    vowel: 'sonic-pi-fx_vowel',
    whammy: 'sonic-pi-fx_whammy',
    wobble: 'sonic-pi-fx_wobble'
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

  def kill_all() do
    GenServer.cast(@me, {:kill_all})
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

    synth_node = Node.next_node()

    OSC.new_synth(name, synth_node.id, :tail, container_group.id, options)

    fx = %FX{synth_node: synth_node, container_group: container_group, synth_group: synth_group}

    {:reply, fx, %{state | effects: [fx | state.effects]}}
  end

  def handle_cast({:kill_all}, state) do
    Enum.each state.effects, fn effect ->
      Group.delete_group(effect.container_group.id)
      Group.delete_group(effect.synth_group.id)
    end
    Group.reset_synth_group()
    {:noreply, %{state | effects: []}}
  end
end
