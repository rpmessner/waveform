defmodule Waveform.Synth.Def.Ugens.Physical do
  @ugens %{
    DWGBowed: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DWGBowedSimple: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DWGBowedTor: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DWGPlucked: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DWGPlucked2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DWGPluckedStiff: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiodeRingMod: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MdaPiano: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    NTube: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    OteyPiano: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    OteyPianoStrings: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Stk: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    StkGlobals: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    StkInst: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TwoTube: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
