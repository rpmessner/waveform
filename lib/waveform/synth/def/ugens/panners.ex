defmodule Waveform.Synth.Def.Ugens.Panners do
  @ugens %{
    Balance2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [left: nil, right: nil, pos: 0, level: 1]
    },
    LinPan2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    Pan2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    Pan4: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    PanAz: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    PanX: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    Rotate2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    Splay: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    SplayAz: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    SplayZ: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    VBAP: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    VBAPSpeaker: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    VBAPSpeakerArray: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
