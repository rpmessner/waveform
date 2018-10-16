defmodule Waveform.Synth.Def.Util do
  alias Waveform.Synth.Def.Parse, as: Parse

  @envelope_defaults %{
    attack: 0,
    decay: 0,
    sustain: 0,
    release: 1,
    attack_level: 1,
    decay_level: -1,
    sustain_level: 1,
    env_curve: 1,
    min: 0
  }

  @envelope_values [
    :min,
    4,
    -99,
    -99,
    :attack_level,
    :attack,
    :env_curve,
    1,
    :decay_level,
    :decay,
    :env_curve,
    0,
    :sustain_level,
    :sustain,
    :env_curve,
    0,
    :min,
    :release,
    :env_curve,
    0
  ]

  def envelope({synth, i}, options \\ []) do
    @envelope_values
    |> Enum.reduce({synth, []}, fn value, {synth, inputs} ->
      input_value =
        if is_number(value) do
          value
        else
          case Keyword.get(options, value) do
            nil -> Map.get(@envelope_defaults, value)
            x -> x
          end
        end

      {synth, input} = Parse.parse({synth, i}, input_value)

      {synth, inputs ++ [input]}
    end)
  end
end
