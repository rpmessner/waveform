defmodule Waveform.Synth.Def.Parse do
  alias Waveform.Synth.Def.Submodule, as: Submodule
  alias Waveform.Synth.Def.Synth, as: Synth
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Ugen.Input, as: Input
  alias Waveform.Synth.Def.Ugens, as: Ugens
  alias Waveform.Synth.Def.Envelope, as: Env

  @unary_op_specials Ugens.Algebraic.unary_ops()
  @binary_op_specials Ugens.Algebraic.binary_ops()

  @kr %{rate: 1}
  @ar %{rate: 2}

  def parse(%Synth{} = synth, definition), do: parse({synth, nil}, definition)

  # parse list
  def parse({%Synth{} = synth, _i}, items) when is_list(items) do
    Enum.reduce(items, {synth, []}, fn item, {s, inputs} ->
      {s, next_input} = parse({s, inputs}, item)
      {s, List.flatten(inputs ++ [next_input])}
    end)
  end

  # parse assignment
  def parse(
        {%Synth{} = synth, i},
        {:=, _, [{output_name, _, nil}, expression]}
      ) do
    {%Synth{assigns: assigns} = synth, input} = parse({synth, i}, expression)

    assigns = Map.put(assigns, output_name, input)

    {%{synth | assigns: assigns}, input}
  end

  # parse destructuring assignment
  def parse(
        {%Synth{} = synth, i},
        {:=, _, [outputs, expression]}
      )
      when is_list(outputs) do
    {%Synth{assigns: assigns} = synth, inputs} = parse({synth, i}, expression)

    if !is_list(inputs) || Enum.count(inputs) < Enum.count(outputs) do
      raise %MatchError{
        term: Macro.to_string(expression)
      }
    end

    assigns =
      outputs
      |> Enum.with_index()
      |> Enum.reduce(assigns, fn {assign, i}, acc ->
        case assign do
          {name, _, nil} ->
            Map.put(acc, name, Enum.at(inputs, i))

          _ ->
            raise "only assignments allowed on left-side of expression"
        end
      end)

    {%{synth | assigns: assigns}, inputs}
  end

  # parse struct ugen/submodule
  def parse(
        {%Synth{} = synth, i},
        {:%, _,
         [
           ugen_name,
           {:%{}, _, options}
         ]}
      ) do
    parse_submodule({synth, i}, ugen_name, options) ||
      parse_ugen({synth, i}, ugen_name, options)
  end

  # parse envelope fn
  def parse(
        {%Synth{} = synth, i},
        {{:., _, [{:__aliases__, _, [env]}, function]}, _, args}
      ) when env in [:Env, :Envelope] do
    parse({synth, i}, apply(Env, function, args))
  end

  # parse module ugen/submodule
  def parse(
        {%Synth{} = synth, i},
        {{:., _, [{:__aliases__, _, _}, _]} = ugen_name, _, [options]}
      ) do
    ugen_name = {ugen_name, nil, []}
    parse_submodule({synth, i}, ugen_name, options) ||
      parse_ugen({synth, i}, ugen_name, options)
  end

  # parse if/else
  def parse(
        {%Synth{} = synth, i},
        {:if, _, [condition, [do: arg1, else: arg2]]}
      ) do
    {synth, input1} = parse({synth, i}, condition)
    {synth, input2} = parse({synth, i}, arg1)
    {synth, input3} = parse({synth, i}, arg2)

    rate1 = lookup_rate(synth, input1)
    rate2 = lookup_rate(synth, input2)
    rate3 = lookup_rate(synth, input3)

    rate = Enum.max([rate1, rate2, rate3])

    operator = %Ugen{
      rate: rate,
      special: 0,
      inputs: List.flatten([input1, input2, input3]),
      outputs: [rate],
      name: "Select"
    }

    {
      %{synth | ugens: synth.ugens ++ [operator]},
      [%Input{src: Enum.count(synth.ugens), constant_index: 0}]
    }
  end

  # parse unless/else
  def parse(
        {%Synth{} = s, i},
        {:unless, ln, [condition, [do: arg1, else: arg2]]}
      ) do
    parse({s, i}, {:if, ln, [condition, [do: arg2, else: arg1]]})
  end

  # pipe operator left-hand map right-hand ugen
  def parse(
        {%Synth{} = s, i},
        {:|>, _,
         [
           {:%{}, _, inputs},
           {:%, ln2,
            [
              {:__aliases__, ln3, [ugen]},
              {:%{}, ln4, options}
            ]}
         ]}
      ) do
    options = Keyword.merge(options, inputs)
    parse({s, i}, {:%, ln2, [{:__aliases__, ln3, [ugen]}, {:%{}, ln4, options}]})
  end

  # pipe operator left-hand tuple right-hand ugen
  def parse(
        {%Synth{} = s, i},
        {:|>, _,
         [
           {name, value},
           {:%, ln2,
            [
              {:__aliases__, ln3, [ugen]},
              {:%{}, ln4, options}
            ]}
         ]}
      ) do
    options = Keyword.put(options, name, value)
    parse({s, i}, {:%, ln2, [{:__aliases__, ln3, [ugen]}, {:%{}, ln4, options}]})
  end

  # pipe operator right-hand ugen
  def parse(
        {%Synth{} = s, i},
        {:|>, _,
         [
           arg,
           {:%, ln2,
            [
              {:__aliases__, ln3, [ugen]},
              {:%{}, ln4, options}
            ]}
         ]}
      ) do
    {name, _} =
      case Ugens.lookup(ugen) do
        %{arguments: [args | _]} -> args
        _ -> {:first, nil}
      end

    parse({s, i}, {:%, ln2, [{:__aliases__, ln3, [ugen]}, {:%{}, ln4, [{name, arg}] ++ options}]})
  end

  # pipe operator right-hand unary
  def parse({%Synth{} = s, i}, {:|>, ln, [arg, {operator, _, nil}]}) do
    parse({s, i}, {operator, ln, [arg]})
  end

  # pipe operator right-hand binary
  def parse({%Synth{} = s, i}, {:|>, _, [arg1, {operator, ln, [arg2]}]}) do
    parse({s, i}, {operator, ln, [arg1, arg2]})
  end

  # parse binary op
  def parse(
        {%Synth{} = synth, i},
        {operator, _, [arg1, arg2]} = expression
      ) do
    special = Map.get(@binary_op_specials, operator)

    if special == nil do
      raise "unknown operator #{Macro.to_string(operator)} " <>
              "when parsing #{Macro.to_string(expression)}"
    end

    {synth, input1} = parse({synth, i}, arg1)
    {synth, input2} = parse({synth, i}, arg2)

    rate1 = lookup_rate(synth, input1)
    rate2 = lookup_rate(synth, input2)

    rate = max(rate1, rate2)

    operator = %Ugen{
      rate: rate,
      special: special,
      inputs: List.flatten([input1, input2]),
      outputs: [rate],
      name: "BinaryOpUGen"
    }

    %Synth{ugens: ugens} = synth

    {
      %{synth | ugens: ugens ++ [operator]},
      [%Input{src: Enum.count(ugens), constant_index: 0}]
    }
  end

  # parse negative constant
  def parse({synth, i}, {:-, _, [val]}) when is_number(val) do
    parse({synth, i}, -val)
  end

  # parse unary op
  def parse(
        {%Synth{} = synth, i},
        {operator, _, [arg]} = expression
      ) do
    special = Map.get(@unary_op_specials, operator)

    if special == nil do
      raise "unknown operator #{Macro.to_string(operator)} " <>
              "when parsing #{Macro.to_string(expression)}"
    end

    {synth, input} = parse({synth, i}, arg)

    rate = lookup_rate(synth, input)

    operator = %Ugen{
      rate: rate,
      special: special,
      inputs: List.flatten([input]),
      outputs: [rate],
      name: "UnaryOpUGen"
    }

    %Synth{ugens: ugens} = synth

    {
      %{synth | ugens: ugens ++ [operator]},
      [%Input{src: Enum.count(ugens), constant_index: 0}]
    }
  end

  # parse variable
  def parse(
        {%Synth{assigns: assigns, parameters: params} = synth, _i},
        {name, _, nil}
      ) do
    saved_assign = Map.get(assigns, name)
    saved_param = Map.get(params, name)

    input =
      cond do
        saved_assign -> saved_assign
        saved_param -> saved_param
        true -> raise "unknown variable #{name}"
      end

    {synth, input}
  end

  # parse constant
  def parse({%Synth{constants: constants} = synth, _i}, arg)
      when is_float(arg) or is_integer(arg) do
    arg = arg + 0.0

    case Enum.find_index(constants, &(&1 == arg)) do
      nil ->
        {
          %{synth | constants: constants ++ [arg]},
          [%Input{src: -1, constant_index: Enum.count(constants)}]
        }

      index ->
        {
          synth,
          [%Input{src: -1, constant_index: index}]
        }
    end
  end

  def parse({%Synth{}, _i}, value) do
    IO.inspect(value)
    raise "Cannot parse expression #{Macro.to_string(value)}"
  end

  defp lookup_rate(_synth, %Input{src: -1}), do: 1
  defp lookup_rate(_synth, []), do: 2
  defp lookup_rate(%Synth{} = s, [%Input{} = i]), do: lookup_rate(s, i)

  defp lookup_rate(%Synth{ugens: ugens}, %Input{src: sidx, constant_index: cidx}) do
    Enum.at(ugens, sidx).outputs |> Enum.at(cidx)
  end

  defp parse_submodule({synth, i}, name, _options) do
    case name do
      {:__aliases__, _, [name]} ->
        submodule = Submodule.lookup(name)

        if submodule do
          {synth, i} = parse({synth, i}, submodule.forms)
          count = Enum.count(List.last(synth.ugens).outputs)
          {synth, Enum.take(List.flatten(i), -count)}
        end

      _ ->
        nil
    end
  end

  defp parse_ugen({synth, i}, ugen_name, options) do
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
    {synth, mul_in} = parse({synth, input}, mul || 1.0)
    {synth, add_in} = parse({synth, input}, add || 0.0)

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
    {%Synth{} = synth, input} = parse({synth, i}, expression)

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
