defmodule Waveform.Synth.Def.Ugens do
  alias Waveform.Synth.Def.Ugens.Algebraic
  alias Waveform.Synth.Def.Ugens.Analysis
  alias Waveform.Synth.Def.Ugens.Buffer
  alias Waveform.Synth.Def.Ugens.Chaotic
  alias Waveform.Synth.Def.Ugens.Delays
  alias Waveform.Synth.Def.Ugens.Demand
  alias Waveform.Synth.Def.Ugens.Deterministic
  alias Waveform.Synth.Def.Ugens.Dynamics
  alias Waveform.Synth.Def.Ugens.Envelopes
  alias Waveform.Synth.Def.Ugens.FFT
  alias Waveform.Synth.Def.Ugens.Filters
  alias Waveform.Synth.Def.Ugens.Granular
  alias Waveform.Synth.Def.Ugens.InOut
  alias Waveform.Synth.Def.Ugens.Interaction
  alias Waveform.Synth.Def.Ugens.Maths
  alias Waveform.Synth.Def.Ugens.Panners
  alias Waveform.Synth.Def.Ugens.Physical
  alias Waveform.Synth.Def.Ugens.Random
  alias Waveform.Synth.Def.Ugens.Reverbs
  alias Waveform.Synth.Def.Ugens.Select
  alias Waveform.Synth.Def.Ugens.Stochastic
  alias Waveform.Synth.Def.Ugens.Synthesis
  alias Waveform.Synth.Def.Ugens.Triggers

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

  def lookup(name) do
    Map.get(@definitions, name)
  end
end
