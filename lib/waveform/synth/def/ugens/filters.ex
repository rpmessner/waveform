defmodule Waveform.Synth.Def.Ugens.Filters do
  @ugens %{
    Allpass1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200]
    },
    APF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, radius: 0.8]
    },
    Allpass2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200]
    },
    BAllPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1]
    },
    BBandPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, bw: 1]
    },
    BBandStop: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, bw: 1]
    },
    BHiPass4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1]
    },
    BHiPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1]
    },
    BHiShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rs: 1, db: 0]
    },
    BLowPass4: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1]
    },
    BLowPass: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1]
    },
    BLowShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rs: 1, db: 0]
    },
    BMoog: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 440, q: 0.2, mode: 0, saturation: 0.95]
    },
    BPeakEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1200, rq: 1, db: 0]
    },
    BPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1]
    },
    BPZ2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    BRF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1]
    },
    BRZ2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    Changed: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [input: nil, threshold: 0]
    },
    CircleRamp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lagTime: 0.1, circmin: -180, circmax: 180]
    },
    ComplexRes: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 100, decay: 0.2]
    },
    CrossoverDistortion: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, amp: 0.5, smooth: 0.5]
    },
    DFM1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 1000, res: 0.1, inputgain: 1,
                  type: 0, noiselevel: 0.0003]
    },
    Decimator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, rate: 44100, bits: 24]
    },
    DiodeRingMod: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [car: 0, mod: 0]
    },
    Disintegrator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, probability: 0.5, multiplier: 0]
    },
    Friction: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, friction: 0.5, spring: 0.414, damp: 0.313,
                  mass: 0.1, beltmass: 1]
    },
    FOS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, a0: 0, a1: 0, b1: 0]
    },
    Formlet: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, attacktime: 1, decaytime: 1]
    },
    Gammatone: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [input: nil, centrefrequency: 440, bandwidth: 200]
    },
    GlitchBPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [n: 0, freq: 440, rq: 1]
    },
    GlitchBRF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [n: 0, freq: 440, rq: 1]
    },
    GlitchHPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440]
    },
    GlitchRHPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1]
    },
    Goertzel: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, bufsize: 1024, freq: nil, hop: 1]
    },
    HairCell: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, spontaneousrate: 0, boostrate: 200,
                  restorerate: 1000, loss: 0.99]
    },
    HPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440]
    },
    HPZ1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    HPZ2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    IIRFilter: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 440, rq: 1]
    },
    InsideOut: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    LTI: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, bufnuma: 0, bufnumb: 1]
    },
    Lag2UD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time_u: 0.1, lag_time_d: 0.1]
    },
    Lag3UD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time_u: 0.1, lag_time_d: 0.1]
    },
    LagUD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time_u: 0.1, lag_time_d: 0.1]
    },
    LPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440]
    },
    LPZ1: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    LPZ2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    Lag: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time: 0.1]
    },
    Lag2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time: 0.1]
    },
    Lag3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time: 0.1]
    },
    LeakDC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, coef: 0.995]
    },
    MeanTriggered: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, trig: 0, length: 10]
    },
    Meddis: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil]
    },
    MedianTriggered: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, trig: 0, length: 10]
    },
    MidEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1, db: 0]
    },
    MoogFF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 100, gain: 2, reset: 0]
    },
    MoogLadder: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, ffreq: 440, res: 0]
    },
    MoogVCF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, fco: nil, res: nil]
    },
    NL2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, bufnum: 0, maxsizea: 10, maxsizeb: 10,
                  guard1: 1000, guard2: 100]
    },
    NL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, bufnuma: 0, bufnumb: 1, guard1: 1000,
                  guard2: 100]
    },
    NLFiltC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, a: nil, b: nil, d: nil, c: nil,
                  l: nil]
    },
    NLFiltL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, a: nil, b: nil, d: nil, c: nil,
                  l: nil]
    },
    NLFiltN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, a: nil, b: nil, d: nil, c: nil,
                  l: nil]
    },
    OnePole: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, coef: 0.5]
    },
    OneZero: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, coef: 0.5]
    },
    RHPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1]
    },
    RLPF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, rq: 1]
    },
    RLPFD: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, ffreq: 440, res: 0, dist: 0]
    },
    RMEQ: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 440, rq: 0.1, k: 0]
    },
    RMShelf2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 440, k: 0]
    },
    RMShelf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, freq: 440, k: 0]
    },
    Ramp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, lag_time: 0.1]
    },
    Resonz: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, bwr: 1]
    },
    Ringz: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, decaytime: 1]
    },
    SOS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, a0: 0, a1: 0, a2: 0, b1: 0, b2: 0]
    },
    SVF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [signal: nil, cutoff: 2200, res: 0.1,
                  lowpass: 1, bandpass: 0, highpass: 0,
                  notch: 0, peak: 0]
    },
    SineShaper: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, limit: 1]
    },
    Slope: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0]
    },
    SmoothDecimator: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, rate: 44100, smoothing: 0.5]
    },
    Streson: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, delayTime: 0.003, res: 0.9]
    },
    TwoPole: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, radius: 0.8]
    },
    TwoZero: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, freq: 440, radius: 0.8]
    },
    VarLag: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, time: 0.1, curvature: 0, warp: 5,
                  start: nil]
    }
  }

  def definitions do
    @ugens
  end
end
