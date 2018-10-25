defmodule Waveform.Synth.Def.Ugens.Interaction do
  @ugens %{
    KeyState: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [keycode: 0, minval: 0, maxval: 1, lag: 0.2]
    },
    MouseButton: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [minval: 0, maxval: 1, lag: 0.2]
    },
    MouseX: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [minval: 0, maxval: 1, warp: 0, lag: 0.2]
    },
    MouseY: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [minval: 0, maxval: 1, warp: 0, lag: 0.2]
    }
  }

  def definitions do
    @ugens
  end
end
