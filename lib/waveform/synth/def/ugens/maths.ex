defmodule Waveform.Synth.Def.Ugens.Maths do
  @ugens %{
    Clip: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Fold: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    InRange: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    InRect: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Integrator: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LeastChange: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LinExp: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LinLin: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [in: 0.0, srclo: 0.0, srchi: 1.0, dstlo: 1.0, dsthi: 2.0]
    },
    ModDif: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    MostChange: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    MulAdd: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [in: nil, *: 1, +: 0]
    },
    RunningMax: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    RunningMin: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    RunningSum: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Schmidt: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Slope: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TrigAvg: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Wrap: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
