defmodule Waveform.Synth.Def.Ugens.Triggers do
  @ugens %{
    Changed: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Gate: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    InTrig: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    LastValue: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Latch: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Phasor: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    PulseCount: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    PulseDivider: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    SendReply: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [trig: 0, reply_id: -1, cmd_name: nil, values: :array]
    },
    SendTrig: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    SetResetFF: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Stepper: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Summer: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Sweep: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    T2A: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    T2K: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TBetaRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TBrownRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TChoose: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TDelay: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TExpRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TGaussRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TIRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TRand: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TWChoose: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    TWindex: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Timer: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    ToggleFF: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Trig: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    Trig1: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    },
    WrapSummer: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: []
    }
  }

  def definitions do
    @ugens
  end
end
