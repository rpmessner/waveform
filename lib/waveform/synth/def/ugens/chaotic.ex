defmodule Waveform.Synth.Def.Ugens.Chaotic do
  @ugens %{
    ArneodoCoulletTresser: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 22050, alpha: 1.5, h: 0.05, xi: 0.5, yi: 0.5, zi: 0.5]
    },
    Breakcore: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: 0, capturein: nil, capturetrigger: nil, duration: 0.1, ampdropout: nil]
    },
    Brusselator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [reset: 0, rate: 0.01, mu: 1, gamma: 1, initx: 0.5, inity: 0.5]
    },
    ChaosGen: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    CuspL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    CuspN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DNoiseRing: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DoubleWell: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DoubleWell2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DoubleWell3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FBSineC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FBSineL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FBSineN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FincoSprottL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FincoSprottM: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FincoSprottS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FitzHughNagumo: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    GbmanL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    GbmanN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    GravityGrid: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    GravityGrid2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    HenonC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    HenonL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    HenonN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LatoocarfianC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LatoocarfianL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LatoocarfianN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LinCongC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LinCongL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LinCongN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Logistic: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LorenzL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LotkaVolterra: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MCLDChaosGen: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Oregonator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Perlin3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    QuadC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    QuadL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    QuadN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMAFoodChainL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RosslerL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RosslerResL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SinOscFB: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SpruceBudworm: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    StandardL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    StandardN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TermanWang: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WeaklyNonlinear: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WeaklyNonlinear2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
