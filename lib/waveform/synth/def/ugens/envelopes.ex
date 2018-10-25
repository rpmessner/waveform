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
      arguments: [envelope: nil, index: nil]
    },
    Line: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [start: 0, end: 1, dur: 1, done: 0]
    },
    Linen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [gate: 1, attack_time: 0.01, sus_level: 1,
                  release_time: 1, done: 0]
    },
    XLine: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [start: 1, end: 2, dur: 1, done: 0]
    }
  }

  def definitions do
    @ugens
  end
end
