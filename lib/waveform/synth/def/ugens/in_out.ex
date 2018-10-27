defmodule Waveform.Synth.Def.Ugens.InOut do
  @ugens %{
    AudioIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiskIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiskOut: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [bufnum: nil, channels: :array]
    },
    In: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    InBus: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    InFeedback: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    InTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LagIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LocalIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LocalOut: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [channels: nil]
    },
    MaxLocalBufs: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    OffsetOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Out: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [bus: 0, channels: :array]
    },
    ReplaceOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SharedIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SharedOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SoundIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    VDiskIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    XOut: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [bus: nil, xfade: nil, channels: :array]
    }
  }

  def definitions do
    @ugens
  end
end
