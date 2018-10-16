defmodule Waveform.Synth.Def.Ugens.Stochastic do
  @ugens %{
    BrownNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    ClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    CoinGate: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Crackle: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Dust: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Dust2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Fhn2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Fhn2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Fhn2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    GaussTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gbman2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gbman2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gbman2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gendy1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gendy2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gendy3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gendy4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Gendy5: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    GrayNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Henon2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Henon2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Henon2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFBrownNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFBrownNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFBrownNoise2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFDClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFDNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFDNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFDNoise3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LFNoise2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Latoocarfian2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Latoocarfian2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Latoocarfian2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Lorenz2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Lorenz2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Lorenz2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    LorenzTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    MarkovSynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    PinkNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    RandID: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    RandSeed: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Sieve1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Standard2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Standard2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    Standard2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    },
    WhiteNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, mul: 1, add: 0]
    }
  }

  def definitions do
    @ugens
  end
end
