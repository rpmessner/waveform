defmodule Waveform.Synth.Def.Ugens.Panners do
  @ugens %{
    Balance2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [left: nil, right: nil, pos: 0, level: 1]
    },
    LinPan2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [left: nil, right: nil, pos: 0, level: 1]
    },
    Pan2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [in: nil, pos: 0, level: 1]
    },
    Pan4: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [in: nil, xpos: 0, ypos: 0, level: 1]
    },
    PanAz: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [num_chans: nil, in: nil, pos: 0, level: 1, width: 2, orientation: 0.5]
    },
    PanX: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [num_chans: nil, in: nil, pos: 0, level: 1, width: 2]
    },
    Rotate2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [x: nil, y: nil, pos: 0]
    },
    Splay: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [in_array: nil, spread: 1, level: 1, center: 0, level_comp: true]
    },
    SplayAz: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [num_chans: 4, in_array: nil, spread: 1, level: 1, width: 2, center: 0, orientation: 0.5, level_comp: true]
    },
    SplayZ: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [num_chans: 4, in_array: nil, spread: 1, level: 1, width: 2, center: 0, orientation: 0.5, level_comp: true]
    },
    VBAP: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [num_chans: nil, in: nil, bufnum: nil, azimuth: 0, elevation: 1, spread: 0]
    },
    VBAPSpeaker: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [azi: nil, ele: nil]
    },
    VBAPSpeakerArray: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: [dim: nil, directions: nil]
    }
  }

  def definitions do
    @ugens
  end
end
