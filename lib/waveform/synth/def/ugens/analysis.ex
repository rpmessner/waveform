defmodule Waveform.Synth.Def.Ugens.Analysis do
  @ugens %{
    AmpComp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: nil, root: nil, exp: 0.3333]
    },
    AmpCompA: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 1000, root: 0, minAmp: 0.32, rootAmp: 1]
    },
    Amplitude: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, attack_time: 0.01, release_time: 0.01]
    },
    AmplitudeMod: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, attack_time: 0.01, release_time: 0.01]
    },
    AnalyseEvents2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, bufnum: 0, threshold: 0.34,
                  triggerid: 101, circular: 0, pitch: 0]
    },
    ArrayMax: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [array: nil]
    },
    ArrayMin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [array: nil]
    },
    AttackSlope: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, windowsize: 1024, peakpicksize: 20, leak: 0.999,
                  energythreshold: 0.01, sumthreshold: 20, mingap: 30,
                  numslopesaveraged: 10]
    },
    AutoTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, lock: 0]
    },
    AverageOutput: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, trig: 0]
    },
    BeatStatistics: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [fft: nil, leak: 0.995, numpreviousbeats: 4]
    },
    BufMax: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: 0, gate: 1]
    },
    BufMin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: 0, gate: 1]
    },
    Chromagram: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [fft: nil, fftsize: 2048, n: 12, tuningbase: 32.703195662575,
                  octaves: 8, integrationflag: 0, coeff: 0.9, octaveratio: 2,
                  perframenormalize: 0]
    },
    Coyote: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, track_Fall: 0.2, slow_lag: 0.2, fast_lag: 0.01,
                  fast_mul: 0.5, thresh: 0.05, min_dur: 0.1]
    },
    Crest: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, numsamps: 400, gate: 1]
    },
    DetectSilence: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, amp: 0.0001, time: 0.1, done: 0]
    },
    DrumTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, lock: 0, dynleak: 0, tempowt: 0,
                  phasewt: 0, basswt: 0, patternwt: 1, prior: nil,
                  kicksensitivity: 1, snaresensitivity: 1, debugmode: 0]
    },
    EnvDetect: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, attack: 100, release: 0]
    },
    EnvFollow: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, decaycoeff: 0.99]
    },
    FeatureSave: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [features: nil, trig: nil]
    },
    FrameCompare: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [buffer1: nil, buffer2: nil, w_amount: 0.5]
    },
    Gammatone: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, centrefrequency: 440, bandwidth: 200]
    },
    HairCell: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, spontaneousrate: 0, boostrate: 200,
                  restorerate: 1000, loss: 0.99]
    },
    KMeansRT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: nil, inputdata: nil, k: 5, gate: 1, reset: 0, learn: 1]
    },
    KeyClarity: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [chain: nil, keydecay: 2, chromaleak: 0.5]
    },
    KeyMode: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [chain: nil, keydecay: 2, chromaleak: 0.5]
    },
    KeyTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [chain: nil, keydecay: 2, chromaleak: 0.5]
    },
    LPCAnalyzer: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, source: 0.01, n: 256, p: 10, testE: 0,
                  delta: 0.999, windowtype: 0]
    },
    LPCError: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, p: 10]
    },
    Loudness: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [chain: nil, smask: 0.25, tmask: 1]
    },
    MFCC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [chain: nil, numcoeff: 13]
    },
    MatchingP: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [dict: 0, in: 0, dictsize: 1, ntofind: 1, hop: 1, method: 0]
    },
    MatchingPResynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [dict: nil, method: 0, trigger: nil, residual: nil]
    },
    Meddis: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil]
    },
    NearestN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [treebuf: nil, in: nil, gate: 1, num: 1]
    },
    OnsetStatistics: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: nil, windowsize: 1, hopsize: 0.1]
    },
    Onsets: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      #odftype:
      #nPOWER=0, MAGSUM=1, COMPLEX=2, RCOMPLEX=3, PHASE=4, WPHASE=5, MKL=6
      arguments: [chain: nil, threshold: 0.5, odftype: 3,
                  relaxtime: 1, floor: 0.1, mingap: 10, medianspan: 11,
                  whtype: 1, rawodf: 0]
    },
    Peak: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, trig: 0]
    },
    PeakFollower: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [in: 0, decay: 0.999]
    },
    Pitch: %{
      defaults: %{rate: 1, special: 0, outputs: [1, 1]},
      arguments: [in: 0, init_freq: 440, min_freq: 60, max_freq: 4000, exec_freq: 100, max_bins_per_octave: 16, median: 1, amp_threshold: 0.01, peak_threshold: 0.5, down_sample: 1, clar: 0]
    },
    Qitch: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RMS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    RunningSum: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SLOnset: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SMS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SOMRd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SOMTrain: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SendPeakRMS: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SensoryDissonance: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Slope: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SpectralEntropy: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TPV: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Tartini: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TrigAvg: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WAmp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WalshHadamard: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    WaveletDaub: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ZeroCrossing: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
