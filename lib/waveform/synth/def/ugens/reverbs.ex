defmodule Waveform.Synth.Def.Ugens.Reverbs do
  @ugens %{
    FreeVerb: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FreeVerb2: %{
      defaults: %{rate: 2, special: 0, outputs: [2, 2]},
      arguments: []
    },
    GVerb: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    JPverb: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    JPverbRaw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
