defmodule Waveform.Synth.Def.Ugens.Select do
  @ugens %{
    LinSelectX: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LinXFade2: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Select: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    SelectX: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    SelectXFocus: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    XFade2: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
