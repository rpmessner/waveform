defmodule Waveform.Synth.Def.Ugens.Dynamics do
  @ugens %{
    Compander: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    CompanderD: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Limiter: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Normalizer: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
  }

  def definitions do
    @ugens
  end
end
