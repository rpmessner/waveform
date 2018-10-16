defmodule Waveform.Synth.Def.Ugens.Demand do
  @ugens %{
    DNoiseRing: %{},
    Dbrown: %{},
    Dbrown2: %{},
    DbufTag: %{},
    Dbufrd: %{},
    Dbufwr: %{},
    Dconst: %{},
    Demand: %{
      arguments: [trig: nil, reset: nil, demand: nil]
    },
    DemandEnvGen: %{},
    DetaBlockerBuf: %{},
    Dfsm: %{},
    Dgeom: %{},
    Dibrown: %{},
    Diwhite: %{},
    Dneuromodule: %{},
    Dpoll: %{
      arguments: [in: nil, run: 1, trigid: -1, label: nil]
    },
    Drand: %{},
    Dreset: %{},
    Dseq: %{
      arguments: [repeats: 1, list: :last]
    },
    Dser: %{
      arguments: [repeats: 1, list: :last]
    },
    Dseries: %{},
    Dshuf: %{},
    Dstutter: %{},
    Dswitch: %{},
    Dswitch1: %{
      arguments: [index: nil, list: :last]
    },
    Dtag: %{},
    Dunique: %{},
    Duty: %{},
    Dwhite: %{},
    Dwrand: %{},
    Dxrand: %{},
    TDuty: %{},
    Unpack1FFT: %{},
    UnpackFFT: %{}
  }

  def definitions do
    @ugens
  end
end
