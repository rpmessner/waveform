defmodule Waveform.Synth.Def.Compile do
  alias Waveform.Synth.Def, as: Def
  alias Waveform.Synth.Def.Synth, as: Synth
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Ugen.Input, as: Input

  def compile(%Def{} = data, version \\ 1) do
    prefix() <> version(version) <> num_defs(data, version) <> definitions(data, version)
  end

  defp prefix(), do: "SCgf"
  defp version(1), do: <<1::size(32)>>
  defp version(2), do: <<2::size(32)>>

  defp num_defs(%Def{synthdefs: synthdefs}, _), do: <<Enum.count(synthdefs)::size(16)>>
  defp num_variants(_, _), do: <<0::size(16)>>

  defp num_constants(%Synth{constants: constants}, 2), do: <<Enum.count(constants)::size(32)>>
  defp num_constants(%Synth{constants: constants}, 1), do: <<Enum.count(constants)::size(16)>>
  defp num_params(%Synth{param_values: params}, 2), do: <<Enum.count(params)::size(32)>>
  defp num_params(%Synth{param_values: params}, 1), do: <<Enum.count(params)::size(16)>>

  defp num_param_names(%Synth{param_names: param_names}, 2),
    do: <<Enum.count(param_names)::size(32)>>

  defp num_param_names(%Synth{param_names: param_names}, 1),
    do: <<Enum.count(param_names)::size(16)>>

  defp num_ugens(%Synth{ugens: ugens}, 2), do: <<Enum.count(ugens)::size(32)>>
  defp num_ugens(%Synth{ugens: ugens}, 1), do: <<Enum.count(ugens)::size(16)>>
  defp num_inputs(%Ugen{inputs: inputs}, 2), do: <<Enum.count(inputs)::size(32)>>
  defp num_inputs(%Ugen{inputs: inputs}, 1), do: <<Enum.count(inputs)::size(16)>>
  defp num_outputs(%Ugen{outputs: outputs}, 2), do: <<Enum.count(outputs)::size(32)>>
  defp num_outputs(%Ugen{outputs: outputs}, 1), do: <<Enum.count(outputs)::size(16)>>

  defp definitions(%Def{synthdefs: [synthdefs | _rest]}, version) do
    Enum.reduce([synthdefs], "", fn %Synth{name: name} = synth, acc ->
      acc <>
        <<String.length(name)>> <>
        name <>
        num_constants(synth, version) <>
        constants(synth) <>
        num_params(synth, version) <>
        parameters(synth) <>
        num_param_names(synth, version) <>
        param_names(synth, version) <>
        num_ugens(synth, version) <> ugens(synth, version) <> num_variants(synth, version)
    end)
  end

  defp ugens(%Synth{ugens: ugens}, version) do
    Enum.reduce(ugens, "", fn %Ugen{name: name, rate: rate, special: special} = u, acc ->
      acc <>
        <<String.length(name)>> <>
        name <>
        <<rate::size(8)>> <>
        num_inputs(u, version) <>
        num_outputs(u, version) <> <<special::size(16)>> <> inputs(u, version) <> outputs(u)
    end)
  end

  defp inputs(%Ugen{inputs: inputs}, 2) do
    Enum.reduce(inputs, "", fn %Input{src: src, constant_index: constant_index}, acc ->
      acc <> <<src::size(32)>> <> <<constant_index::size(32)>>
    end)
  end

  defp inputs(%Ugen{inputs: inputs}, 1) do
    Enum.reduce(inputs, "", fn %Input{src: src, constant_index: constant_index}, acc ->
      acc <> <<src::size(16)>> <> <<constant_index::size(16)>>
    end)
  end

  defp outputs(%Ugen{outputs: outputs}) do
    Enum.reduce(outputs, "", fn k, acc ->
      acc <> <<k::size(8)>>
    end)
  end

  defp param_names(%Synth{param_names: param_names}, 2) do
    param_names
    |> Enum.with_index()
    |> Enum.reduce("", fn {i, k}, acc ->
      acc <> k <> <<i::size(32)>>
    end)
  end

  defp param_names(%Synth{param_names: param_names}, 1) do
    param_names
    |> Enum.with_index()
    |> Enum.reduce("", fn {k, i}, acc ->
      acc <> <<String.length(k)>> <> k <> <<i::size(16)>>
    end)
  end

  defp parameters(%Synth{param_values: params}) do
    Enum.reduce(params, "", fn k, acc ->
      acc <> <<k::size(32)-float>>
    end)
  end

  defp constants(%Synth{constants: constants}) do
    Enum.reduce(constants, "", fn k, acc ->
      acc <> <<k::size(32)-float>>
    end)
  end
end
