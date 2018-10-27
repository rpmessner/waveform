defmodule Waveform.Synth.Def.Ugens.Demand do
  @ugens %{
    DNoiseRing: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dbrown: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dbrown2: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    DbufTag: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dbufrd: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dbufwr: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dconst: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Demand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [trig: nil, reset: nil, demand: nil]
    },
    DemandEnvGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    DetaBlockerBuf: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dfsm: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dgeom: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dibrown: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Diwhite: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dneuromodule: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dpoll: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [in: nil, run: 1, trigid: -1, label: nil]
    },
    Drand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dreset: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dseq: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [repeats: 1, list: :array]
    },
    Dser: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [repeats: 1, list: :array]
    },
    Dseries: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dshuf: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dstutter: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dswitch: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dswitch1: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [index: nil, list: :array]
    },
    Dtag: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dunique: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Duty: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dwhite: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dwrand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Dxrand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TDuty: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Unpack1FFT: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    UnpackFFT: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
