defmodule Waveform.Synth.Def.Ugens.Envelopes do
  @ugens %{
    Decay: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Decay2: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    DemandEnvGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    EnvGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [
        gate: 1,
        level_scale: 1,
        level_bias: 0,
        time_scale: 1,
        done_action: 0,
        envelope: :last
      ]
    },
    IEnvGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Line: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Linen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    XLine: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
