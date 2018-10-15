defmodule Waveform.Synth.Def.Ugens do
  @definitions %{
    EnvGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [:gate, :level_scale, :level_bias, :time_scale, :done_action, :envelope]
    },
    SinOsc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [:freq, :phase, :mul, :add]
    },
    Saw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [],
    },
    Out: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [],
    }
  }

  def definitions do
    @definitions
  end
end
