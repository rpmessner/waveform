defmodule Waveform.Synth.Def.Ugens.Filters do
  @ugens %{
    Allpass1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Allpass2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BAllPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BBandPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BBandStop: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BEQSuite: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BHiPass4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BHiPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BHiShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BLowPass4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BLowPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BLowShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BMoog: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BPeakEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    CrossoverDistortion: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DFM1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Decimator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiodeRingMod: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Disintegrator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Filter: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Friction: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Gammatone: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Goertzel: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    HairCell: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    IIRFilter: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    InsideOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LTI: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Lag2UD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Lag3UD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LagUD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MeanTriggered: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Meddis: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MedianTriggered: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MoogFF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MoogLadder: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MoogVCF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NL2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NLFiltC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NLFiltL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NLFiltN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RLPFD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMEQSuite: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMShelf2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RegaliaMitraEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SVF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SineShaper: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SmoothDecimator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Streson: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
