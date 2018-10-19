defmodule Waveform.Synth.Def.Ugens.Random do
  @ugens %{
    ExpRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Hasher: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LinRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    NRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Rand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TChoose: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
