defmodule Waveform.Synth.Def.Ugens.InOut do
  @ugens %{
    AudioIn: %{},
    DiskIn: %{},
    DiskOut: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [bufnum: nil, channels: :last],
    },
    In: %{},
    InBus: %{},
    InFeedback: %{},
    InTrig: %{},
    LagIn: %{},
    LocalIn: %{},
    LocalOut: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [channels: nil],
    },
    MaxLocalBufs: %{},
    OffsetOut: %{},
    Out: %{
      defaults: %{rate: 2, special: 0, outputs: []},
      arguments: [bus: 0, channels: :last],
    },
    ReplaceOut: %{},
    SharedIn: %{},
    SharedOut: %{},
    SoundIn: %{},
    VDiskIn: %{},
    XOut: %{
      arguments: [bus: nil, xfade: nil, channels: :last]
    }
  }

  def definitions do
    @ugens
  end
end
