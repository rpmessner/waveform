defmodule Waveform.Synth.Def.Ugens.Buffer do
  @ugens %{
    BufRd: %{},
    BufWr: %{
      arguments: [bufnum: 0, phase: 0, loop: 1, inputs: :last]
    },
    Dbufrd: %{},
    Dbufwr: %{},
    DelTapRd: %{},
    DelTapWr: %{},
    DetectIndex: %{},
    DiskIn: %{},
    DiskOut: %{},
    GrainBuf: %{},
    Harmonics: %{},
    Index: %{},
    IndexInBetween: %{},
    IndexL: %{},
    ListTrig: %{},
    ListTrig2: %{},
    LocalBuf: %{},
    Logger: %{},
    LoopBuf: %{},
    MatchingPResynth: %{},
    MultiTap: %{},
    Phasor: %{},
    PlayBuf: %{},
    RecordBuf: %{
      arguments: [
        bufnum: 0,
        offset: 0,
        rec_level: 1,
        pre_level: 0,
        run: 1,
        loop: 1,
        trigger: 1,
        done: 0,
        inputs: :last
      ]
    },
    ScopeOut: %{
      arguments: [inputs: :last]
    },
    ScopeOut2: %{
      arguments: [scope_num: 0, max_frames: 4096, scope_frames: nil, inputs: :last]
    },
    Shaper: %{},
    SortBuf: %{},
    TGrains: %{},
    TGrains2: %{},
    TGrains3: %{},
    Tap: %{},
    VDiskIn: %{},
    VMScan2D: %{},
    Warp1: %{},
    WaveTerrain: %{},
    WrapIndex: %{}
  }

  def definitions do
    @ugens
  end
end
