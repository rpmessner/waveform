defmodule Waveform.Synth.Def.Ugens do
  alias Waveform.Synth.Def.Ugens.Buffer, as: Buffer
  alias Waveform.Synth.Def.Ugens.Chaotic, as: Chaotic
  alias Waveform.Synth.Def.Ugens.Demand, as: Demand
  alias Waveform.Synth.Def.Ugens.Deterministic, as: Deterministic
  alias Waveform.Synth.Def.Ugens.Envelopes, as: Envelopes
  alias Waveform.Synth.Def.Ugens.Filters, as: Filters
  alias Waveform.Synth.Def.Ugens.InOut, as: InOut
  alias Waveform.Synth.Def.Ugens.Panners, as: Panners
  alias Waveform.Synth.Def.Ugens.Select, as: Select
  alias Waveform.Synth.Def.Ugens.Stochastic, as: Stochastic
  alias Waveform.Synth.Def.Ugens.Triggers, as: Triggers

  @definitions [
    Buffer.definitions(),
    Chaotic.definitions(),
    Demand.definitions(),
    Deterministic.definitions(),
    Envelopes.definitions(),
    Filters.definitions(),
    InOut.definitions(),
    Panners.definitions(),
    Select.definitions(),
    Stochastic.definitions(),
    Triggers.definitions()
  ] |> Enum.reduce(%{}, &Map.merge(&1, &2))

  def definitions do
    @definitions
  end
end
