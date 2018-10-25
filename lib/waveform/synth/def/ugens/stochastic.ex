defmodule Waveform.Synth.Def.Ugens.Stochastic do
  @ugens %{
    BrownNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    ClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    CoinGate: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Crackle: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Dust: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Dust2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Fhn2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Fhn2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Fhn2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    GaussTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gbman2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gbman2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gbman2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gendy1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gendy2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gendy3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gendy4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Gendy5: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    GrayNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Henon2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Henon2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Henon2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFBrownNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFBrownNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFBrownNoise2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFDClipNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFDNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFDNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFDNoise3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFNoise0: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFNoise1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LFNoise2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Latoocarfian2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Latoocarfian2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Latoocarfian2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Lorenz2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Lorenz2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Lorenz2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    LorenzTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    MarkovSynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    PinkNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    RandID: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    RandSeed: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Sieve1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Standard2DC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Standard2DL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    Standard2DN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    WhiteNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    }
  }

  def definitions do
    @ugens
  end
end
