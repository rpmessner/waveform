defmodule Waveform.Synth.Def.Ugens.Analysis do
  @ugens %{
    AmpComp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AmpCompA: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Amplitude: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AmplitudeMod: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AnalyseEvents2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ArrayMax: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ArrayMin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AttackSlope: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AutoTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    AverageOutput: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BeatStatistics: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BufMax: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BufMin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Chromagram: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Coyote: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Crest: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DetectSilence: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    DrumTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    EnvDetect: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    EnvFollow: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FeatureSave: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FrameCompare: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Gammatone: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    HairCell: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    KMeansRT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    KeyClarity: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    KeyMode: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    KeyTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LPCAnalyzer: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    LPCError: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Loudness: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MFCC: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MatchingP: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MatchingPResynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Max: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Meddis: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    NearestN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    OnsetStatistics: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Onsets: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Peak: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PeakFollower: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Pitch: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
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
