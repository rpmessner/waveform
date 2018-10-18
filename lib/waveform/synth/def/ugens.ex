defmodule Waveform.Synth.Def.Ugens do
  alias Waveform.Synth.Def.Ugens.Algebraic, as: Algebraic
  alias Waveform.Synth.Def.Ugens.Analysis, as: Analysis
  alias Waveform.Synth.Def.Ugens.Buffer, as: Buffer
  alias Waveform.Synth.Def.Ugens.Chaotic, as: Chaotic
  alias Waveform.Synth.Def.Ugens.Delays, as: Delays
  alias Waveform.Synth.Def.Ugens.Demand, as: Demand
  alias Waveform.Synth.Def.Ugens.Deterministic, as: Deterministic
  alias Waveform.Synth.Def.Ugens.Dynamics, as: Dynamics
  alias Waveform.Synth.Def.Ugens.Envelopes, as: Envelopes
  alias Waveform.Synth.Def.Ugens.FFT, as: FFT
  alias Waveform.Synth.Def.Ugens.Filters, as: Filters
  alias Waveform.Synth.Def.Ugens.Granular, as: Granular
  alias Waveform.Synth.Def.Ugens.InOut, as: InOut
  alias Waveform.Synth.Def.Ugens.Interaction, as: Interaction
  alias Waveform.Synth.Def.Ugens.Maths, as: Maths
  alias Waveform.Synth.Def.Ugens.Panners, as: Panners
  alias Waveform.Synth.Def.Ugens.Physical, as: Physical
  alias Waveform.Synth.Def.Ugens.Random, as: Random
  alias Waveform.Synth.Def.Ugens.Reverbs, as: Reverbs
  alias Waveform.Synth.Def.Ugens.Select, as: Select
  alias Waveform.Synth.Def.Ugens.Stochastic, as: Stochastic
  alias Waveform.Synth.Def.Ugens.Synthesis, as: Synthesis
  alias Waveform.Synth.Def.Ugens.Triggers, as: Triggers

  @definitions [
                 Algebraic.definitions(),
                 Analysis.definitions(),
                 Buffer.definitions(),
                 Chaotic.definitions(),
                 Delays.definitions(),
                 Demand.definitions(),
                 Deterministic.definitions(),
                 Dynamics.definitions(),
                 Envelopes.definitions(),
                 FFT.definitions(),
                 Filters.definitions(),
                 Granular.definitions(),
                 InOut.definitions(),
                 Interaction.definitions(),
                 Maths.definitions(),
                 Panners.definitions(),
                 Physical.definitions(),
                 Reverbs.definitions(),
                 Random.definitions(),
                 Select.definitions(),
                 Stochastic.definitions(),
                 Synthesis.definitions(),
                 Triggers.definitions()
               ]
               |> Enum.reduce(%{}, &Map.merge(&1, &2))

  def definitions do
    @definitions
  end
end
