defmodule Waveform.Synth.Def.Ugens.Buffer do
  @ugens %{
    BufRd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [num_channels: nil, bufnum: 0, phase: 0, loop: 1, interpolation: 2]
    },
    BufWr: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: 0, phase: 0, loop: 1, inputs: :array]
    },
    Dbufrd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: 0, phase: 0, loop: 1]
    },
    Dbufwr: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, bufnum: 0, phase: 0, loop: 1]
    },
    DelTapRd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DelTapWr: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DetectIndex: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiskIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DiskOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    GrainBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Harmonics: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Index: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    IndexInBetween: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    IndexL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ListTrig: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ListTrig2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LocalBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Logger: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LoopBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MatchingPResynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MultiTap: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Phasor: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PlayBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RecordBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [
        bufnum: 0,
        offset: 0,
        rec_level: 1,
        pre_level: 0,
        run: 1,
        loop: 1,
        trigger: 1,
        done: 0,
        inputs: :array
      ]
    },
    ScopeOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [inputs: :array]
    },
    ScopeOut2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [scope_num: 0, max_frames: 4096, scope_frames: nil, inputs: :array]
    },
    Shaper: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SortBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TGrains: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TGrains2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TGrains3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Tap: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    VDiskIn: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    VMScan2D: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Warp1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WaveTerrain: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WrapIndex: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
