defmodule Waveform.Synth.Def.Parse.Ugen do
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Ugen.Input, as: Input
  alias Waveform.Synth.Def.Ugens, as: Ugens
  alias Waveform.Synth.Def.Parse, as: Parse
  alias Waveform.Synth.Def.Synth, as: Synth

  @kr %{rate: 1}
  @ar %{rate: 2}

  def parse({synth, i}, ugen_name, options) do
    {ugen, %{arguments: arguments} = ugen_def} = parse_ugen_name(ugen_name)

    # some ugens can allow an array of inputs
    # for specific params, e.g. %Out{channels:}
    allow_array_args =
      arguments
      |> Enum.filter(fn {_key, value} ->
        value == :array
      end)
      |> Enum.map(fn {key, _value} -> key end)

    # the rest of the array args
    # turn the output ugen into an array
    # e.g. %SinOsc{freq: [400, 600]} = [%SinOsc{freq: 400}, %SinOsc{freq: 600}]
    array_args =
      Enum.filter(options, fn {key, value} ->
        !Enum.member?(allow_array_args, key) && is_list(value)
      end)

    case array_args do
      [] ->
        create_ugen({ugen, {synth, i}}, ugen_def, options)

      _ ->
        num_array_args =
          array_args
          |> Enum.map(fn {_, a} -> Enum.count(a) end)
          |> Enum.max()

        {synth, i} =
          0..(num_array_args - 1)
          |> Enum.reduce({synth, i}, fn arg_index, {synth, input} ->
            options =
              Enum.reduce(array_args, options, fn {key, val}, options ->
                arg = Enum.at(val, arg_index)
                options = Keyword.put(options, key, arg)
                options
              end)

            {synth, i2} = create_ugen({ugen, {synth, input}}, ugen_def, options)
            {synth, List.flatten([input, i2])}
          end)

        {synth, i}
    end
  end

  defp parse_ugen_muladd({u, {s, i}}, nil, nil), do: {u, {s, i}}

  defp parse_ugen_muladd({ugen, {synth, input}}, mul, add) do
    {synth, mul_in} = Parse.parse({synth, input}, mul || 1.0)
    {synth, add_in} = Parse.parse({synth, input}, add || 0.0)

    muladd = %Ugen{
      name: "MulAdd",
      special: 0,
      rate: ugen.rate,
      outputs: [ugen.rate],
      inputs:
        List.flatten([
          %Input{
            src: Enum.count(synth.ugens),
            constant_index: 0
          },
          mul_in,
          add_in
        ])
    }

    {muladd, {%{synth | ugens: synth.ugens ++ [ugen]}, input}}
  end

  defp parse_ugen_name(ugen_name) do
    case ugen_name do
      {:__aliases__, _, [name]} ->
        build_ugen(name, @kr)

      {{:., _, [{:__aliases__, _, [name]}, :kr]}, _, _} ->
        build_ugen(name, @kr, priority: :high)

      {{:., _, [{:__aliases__, _, [name]}, :ar]}, _, _} ->
        build_ugen(name, @ar, priority: :high)

      _ ->
        raise "can't parse ugen/submodule name: #{Macro.to_string(ugen_name)}"
    end
  end

  defp parse_ugen_options({u, {s, i}}, []), do: {u, {s, i}}

  defp parse_ugen_options(
         {
           %Ugen{inputs: inputs} = ugen,
           {synth, i}
         },
         [{_, expression} | rest_options]
       ) do
    {%Synth{} = synth, input} = Parse.parse({synth, i}, expression)

    parse_ugen_options(
      {
        %{ugen | inputs: List.flatten(inputs ++ [input])},
        {synth, input}
      },
      rest_options
    )
  end

  defp create_ugen({ugen, {synth, input}}, %{arguments: arguments}, options) do
    add = Keyword.get(options, :add)
    mul = Keyword.get(options, :mul)

    options = Keyword.drop(options, [:mul, :add])

    option_keys = Keyword.keys(arguments)

    options =
      Keyword.merge(arguments, options)
      |> Enum.sort_by(fn {key, _value} ->
        Enum.find_index(option_keys, &(&1 == key))
      end)

    {ugen, {synth, _input}} =
      {ugen, {synth, input}}
      |> parse_ugen_options(options)
      |> parse_ugen_muladd(mul, add)

    src = Enum.count(synth.ugens)

    inputs =
      ugen.outputs
      |> Enum.with_index()
      |> Enum.map(fn {_output, idx} ->
        %Input{src: src, constant_index: idx}
      end)

    {%{synth | ugens: synth.ugens ++ [ugen]}, inputs}
  end

  defp build_ugen(name, base), do: build_ugen(name, base, priority: :low)

  defp build_ugen(name, base, priority: priority) do
    ugen_def = Ugens.lookup(name)

    unless ugen_def, do: raise("Unknown or unimplemented ugen #{name}")

    %{defaults: ugen_base} = ugen_def

    ugen_name = %{name: to_string(name)}

    options =
      if priority == :high do
        [base, ugen_base, ugen_name]
      else
        [ugen_base, base, ugen_name]
      end

    ugen = Enum.reduce(options, %{}, &Map.merge(&1, &2))

    rate = ugen[:rate]

    num_outputs = Enum.count(ugen_base[:outputs])

    outputs =
      Stream.repeatedly(fn -> rate end)
      |> Enum.take(num_outputs)

    ugen = %{ugen | outputs: outputs}

    {struct(Ugen, ugen), ugen_def}
  end
end
