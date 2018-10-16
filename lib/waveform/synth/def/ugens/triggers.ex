defmodule Waveform.Synth.Def.Ugens.Triggers do
  @ugens %{
    Changed: %{},
    Gate: %{},
    InTrig: %{},
    LastValue: %{},
    Latch: %{},
    Phasor: %{},
    PulseCount: %{},
    PulseDivider: %{},
    SendReply: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [trig: 0, reply_id: -1, cmd_name: :last, values: :last]
    },
    SendTrig: %{},
    SetResetFF: %{},
    Stepper: %{},
    Summer: %{},
    Sweep: %{},
    T2A: %{},
    T2K: %{},
    TBetaRand: %{},
    TBrownRand: %{},
    TChoose: %{},
    TDelay: %{},
    TExpRand: %{},
    TGaussRand: %{},
    TIRand: %{},
    TRand: %{},
    TWChoose: %{},
    TWindex: %{},
    Timer: %{},
    ToggleFF: %{},
    Trig: %{},
    Trig1: %{},
    WrapSummer: %{},
  }

  def definitions do
    @ugens
  end
end
