defmodule Waveform.Synth.Def.Ugens.FFT do
  @ugens %{
    BeatTrack: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    BeatTrack2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Cepstrum: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Convolution: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Convolution2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Convolution2L: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTComplexDev: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTCrest: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTDiffMags: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTFlux: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTFluxPos: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTMKL: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTPeak: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTPhaseDev: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTPower: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTSlope: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTSpread: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTSubbandFlatness: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTSubbandFlux: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTSubbandPower: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FFTTrigger: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    FrameCompare: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    ICepstrum: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    IFFT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    MedianSeparation: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PVInfo: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PVSynth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Add: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinBufRd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinDelay: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinPlayBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinScramble: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinShift: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BinWipe: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BrickWall: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_BufRd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_ChainUGen: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_CommonMag: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_CommonMul: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Compander: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_ConformalMap: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Conj: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Copy: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_CopyPhase: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Cutoff: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Diffuser: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Div: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_EvenBin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_ExtractRepeat: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Freeze: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_FreqBuffer: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_HainsworthFoote: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Invert: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_JensenAndersen: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_LocalMax: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagAbove: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagBelow: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagBuffer: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagClip: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagDiv: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagExp: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagFreeze: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagGate: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagLog: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagMap: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagMinus: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagMul: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagMulAdd: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagNoise: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagShift: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagSmear: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagSmooth: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MagSquared: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Max: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MaxMagN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Min: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_MinMagN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Morph: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Mul: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_NoiseSynthF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_NoiseSynthP: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_OddBin: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PartialSynthF: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PartialSynthP: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PhaseShift: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PhaseShift270: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PhaseShift90: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_PlayBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_RandComb: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_RandWipe: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_RecordBuf: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_RectComb: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_RectComb2: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_SoftWipe: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_SpectralEnhance: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_SpectralMap: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_Whiten: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PV_XFade: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PackFFT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    PartConv: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SpecCentroid: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SpecFlatness: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    SpecPcile: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    StereoConvolution2L: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    TPV: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    Unpack1FFT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    },
    UnpackFFT: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
