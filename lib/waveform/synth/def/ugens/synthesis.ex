defmodule Waveform.Synth.Def.Ugens.Synthesis do
  @ugens %{
    AtsAmp: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsFile: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsFreq: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsNoiSynth: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsNoise: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsParInfo: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsPartial: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsSynth: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    AtsUGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LPCSynth: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LPCVals: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Maxamp: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
