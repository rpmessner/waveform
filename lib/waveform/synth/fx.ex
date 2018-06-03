defmodule Waveform.Synth.FX do
  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Node, as: Node
  alias Waveform.OSC.Group, as: Group

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

  def add_fx(%Group{} = parent, type, options) do
    name = @enabled_fx[type]

    if name do
      container_group = Group.fx_container_group(type, parent)
      synth_group = Group.fx_synth_group(type, container_group)

      synth_node = Node.next_node()

      options = Enum.reduce(options, [], fn ({k, v}, acc) -> [k, v | acc] end)

      OSC.new_synth(name, synth_node.id, :tail, container_group.id, options)

      %{container_group | parent: parent, nodes: [synth_node], children: [synth_group]}
    else
      parent
    end
  end
end
