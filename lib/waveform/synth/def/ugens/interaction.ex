defmodule Waveform.Synth.Def.Ugens.Interaction do
  @ugens %{
    KeyState: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    MouseButton: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    MouseX: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    MouseY: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
