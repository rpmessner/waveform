defmodule Waveform.Synth.Def.Ugens.Deterministic do
  @ugens %{
    Blip: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, numharm: 200]
    },
    BlitB3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    BlitB3Saw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, leak: 0.99]
    },
    BlitB3Square: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, leak: 0.99]
    },
    BlitB3Tri: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, leak: 0.99, leak2: 0.99]
    },
    COsc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: nil, freq: 440, beats: 0.5]
    },
    DPW3Tri: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    DPW4Saw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    DynKlang: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freqscale: 1, freqoffset: 0, specs: nil]
    },
    DynKlank: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [input: nil, freqscale: 1, freqoffset: 0, decayscale: 1, specs: nil]
    },
    FM7: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [ctl_matrix: nil, mod_matrix: nil]
    },
    Klang: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freqscale: 1, freqoffset: 0, specs: nil]
    },
    Klank: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [input: nil, freqscale: 1, freqoffset: 0, decayscale: 1, specs: nil]
    },
    LFCub: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0]
    },
    LFGauss: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [duration: 1, width: 0.1, iphase: 0, loop: 1, done_action: 0]
    },
    LFPar: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0]
    },
    LFPulse: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0, width: 0.5]
    },
    LFSaw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0]
    },
    LFTri: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0]
    },
    Osc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: nil, freq: 440, phase: 0]
    },
    OscN: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufnum: nil, freq: 440, phase: 0]
    },
    PMOsc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [carfreq: nil, modfreq: nil, pmindex: 0, modphase: 0]
    },
    PSinGrain: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, dur: 0.2, amp: 0.1]
    },
    Pulse: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, width: 0.5]
    },
    Saw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440]
    },
    SinOsc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, phase: 1]
    },
    SinOscFB: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, feedback: 0]
    },
    SyncSaw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [sync_freq: 440, saw_freq: 440]
    },
    VOsc: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [bufpos: nil, freq: 440, phase: 0]
    },
    VOsc3: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [buffpos: nil, freq1: 110, freq2: 220, freq3: 440]
    },
    VarSaw: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [freq: 440, iphase: 0, width: 0.5]
    },
    Vibrato: %{
      defaults: %{rate: 2, special: 0, outputs: [2]},
      arguments: [
        freq: 440,
        rate: 6,
        depth: 0.02,
        delay: 0,
        onset: 0,
        rate_variation: 0.04,
        depth_variation: 0.1,
        iphase: 0,
        trig: 0
      ]
    }
  }

  def definitions do
    @ugens
  end
end
