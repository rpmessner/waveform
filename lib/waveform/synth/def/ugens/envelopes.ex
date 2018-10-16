defmodule Waveform.Synth.Def.Ugens.Envelopes do
  @ugens %{
    Decay: %{},
    Decay2: %{},
    DemandEnvGen: %{},
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
    IEnvGen: %{},
    Line: %{},
    Linen: %{},
    XLine: %{}
  }

  def definitions do
    @ugens
  end
end
