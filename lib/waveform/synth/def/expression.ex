defmodule Waveform.Synth.Def.Expression do
  alias Waveform.Synth.Def.Submodule, as: Submodule
  alias Waveform.Synth.Def.Synth, as: Synth
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Ugen.Input, as: Input
  alias Waveform.Synth.Def.Ugens, as: Ugens
  alias Waveform.Synth.Def.Util, as: Util

  @ugens Ugens.definitions

  @unary_op_specials Ugens.BasicOps.unary_ops
  @binary_op_specials Ugens.BasicOps.binary_ops

  def parse_lines(%Synth{} = synth, []), do: synth

  def parse_lines(%Synth{} = synth, [line | rest]) do
    case line do
      {op, _, [{assign_name, _, nil}, expression]} when op in [:<-, :=] ->
        { synth, _input } = parse(synth, line)
        synth
      _ ->
        raise "cannot parse line #{Macro.to_string(line)}"
    end
    |> parse_lines(rest)
  end

  def parse(
         %Synth{} = synth,
         {op, _, [{output_name, _, nil}, expression]}
       ) when op in [:<-, :=] do

    {%Synth{assigns: assigns} = synth, input} = parse(synth, expression)

    assigns = Map.put(assigns, output_name, input)

    {%{synth | assigns: assigns}, input}
  end

  def parse(
         %Synth{} = synth,
         {:%, _,
          [
            ugen_name,
            {:%{}, _, options}
          ]} = ugen
       ) do

    synth =
      case parse_submodule(synth, ugen_name, options) do
        nil ->
          { ugen, arguments } = parse_ugen_name(ugen_name)

          options =
            Enum.sort_by(options, fn {key, _value} ->
              Enum.find_index(Keyword.keys(arguments), &(&1 == key))
            end)

          {
            ugen,
            %Synth{ugens: ugens} = synth,
            _
          } = parse_ugen_options({ugen, synth, options})

          %{synth | ugens: ugens ++ [ugen]}
        synth -> synth
      end

    {
      synth,
      %Input{src: Enum.count(synth.ugens) - 1, constant_index: 0}
    }
  end

  def parse(
         %Synth{} = synth,
         {:if, _, [condition, [do: arg1, else: arg2]]}
       ) do
    {synth, input1} = parse(synth, condition)
    {synth, input2} = parse(synth, arg1)
    {synth, input3} = parse(synth, arg2)

    operator = %Ugen{
      rate: 1,
      special: 0,
      inputs: List.flatten([input1, input2, input3]),
      outputs: [1],
      name: "Select"
    }

    {
      %{synth | ugens: synth.ugens ++ [operator]},
      %Input{src: Enum.count(synth.ugens), constant_index: 0}
    }
  end

  def parse(
         %Synth{ugens: ugens} = synth,
         {operator, _, [arg1, arg2]} = expression
       ) do
    special = Map.get(@binary_op_specials, operator)

    if special == nil do
      raise "unknown operator #{operator} when parsing #{Macro.to_string(expression)}"
    end

    {synth, input1} = parse(synth, arg1)
    {synth, input2} = parse(synth, arg2)

    rate1 = lookup_rate(synth, input1)
    rate2 = lookup_rate(synth, input2)

    rate = max(rate1, rate2)

    # IO.inspect({Macro.to_string(expression), expression, input1, input2})

    operator = %Ugen{
      rate: rate,
      special: special,
      inputs: List.flatten([input1, input2]),
      outputs: [rate],
      name: "BinaryOpUGen"
    }

    {
      %{synth | ugens: ugens ++ [operator]},
      [%Input{src: Enum.count(ugens), constant_index: 0}]
    }
  end

  def parse(
         %Synth{} = synth,
         {{:. , _, [{:__aliases__, _, [:Util]}, function]}, _, [options]}
       ) do

    apply(Util, function, [synth, options])
  end

  def parse(
         %Synth{ugens: ugens} = synth,
         {operator, _, [arg]} = expression
       ) do
    special = Map.get(@unary_op_specials, operator)

    if special == nil do
      IO.inspect(operator)
      raise "unknown operator #{Macro.to_string(operator)} " <>
        "when parsing #{Macro.to_string(expression)}"
    end

    {synth, input} = parse(synth, arg)

    rate = lookup_rate(synth, input)

    operator = %Ugen{
      rate: rate,
      special: special,
      inputs: List.flatten([input]),
      outputs: [rate],
      name: "UnaryOpUGen"
    }

    {
      %{synth | ugens: ugens ++ [operator]},
      [%Input{src: Enum.count(ugens), constant_index: 0}]
    }
  end

  def parse(%Synth{} = synth, {_, _, nil} = value) do
    expression_input(synth, value)
  end

  def parse(%Synth{} = synth, value)
       when is_float(value) or is_integer(value) do
    expression_input(synth, value)
  end

  def parse(%Synth{}, value) do
    raise "Cannot parse expression #{Macro.to_string(value)}"
  end

  defp lookup_rate(_synth, %Input{src: -1}), do: 1
  defp lookup_rate(_synth, []), do: 2 #out
  defp lookup_rate(%Synth{}=s, [%Input{}=i]), do: lookup_rate(s, i)
  defp lookup_rate(%Synth{ugens: ugens}, %Input{src: sidx, constant_index: _cidx}) do
    Enum.at(ugens, sidx).rate
  end

  defp expression_input(
         %Synth{assigns: assigns, parameters: params} = synth,
         {arg_name, _, nil}
       ) do
    {synth, assignment_input(arg_name, assigns, params)}
  end

  defp expression_input(%Synth{constants: constants} = synth, arg)
       when is_float(arg) or is_integer(arg) do
    {
      %{synth | constants: constants ++ [arg + 0.0]},
      %Input{src: -1, constant_index: Enum.count(constants)}
    }
  end

  defp assignment_input(name, assigns, params) do
    saved_assign = Map.get(assigns, name)
    saved_param = Map.get(params, name)

    cond do
      saved_assign -> saved_assign
      saved_param -> saved_param
      true -> raise "unknown constant #{name}"
    end
  end

  @kr %{outputs: [1], rate: 1, special: 0}
  @ar %{outputs: [2], rate: 2, special: 0}

  defp build_ugen(name, base), do: build_ugen(name, base, priority: :low)
  defp build_ugen(name, base, priority: priority) do
    ugen_def = Map.get(@ugens, name)

    unless ugen_def, do: raise "Unknown or unimplemented ugen #{name}"

    %{defaults: ugen_base, arguments: arguments} = ugen_def
    ugen_name = %{name: to_string(name)}

    options = if priority == :high do
      [base, ugen_base, ugen_name]
    else
      [ugen_base, base, ugen_name]
    end

    ugen = Enum.reduce(options, %{}, &Map.merge(&1, &2))
    { ugen, arguments }
  end

  defp parse_ugen_name(ugen_name) do
    {ugen_opts, arguments} = case ugen_name do
      {:__aliases__, _, [name]} ->
        build_ugen(name, @kr)

      {{:., _, [{:__aliases__, _, [name]}, :kr]}, _, _} ->
        build_ugen(name, @kr, priority: :high)

      {{:., _, [{:__aliases__, _, [name]}, :ar]}, _, _} ->
        build_ugen(name, @ar, priority: :high)

      _ ->
        IO.inspect("error") && raise "can't parse #{Macro.to_string(ugen_name)}"
    end

    { struct(Ugen, ugen_opts), arguments }
  end

  defp parse_submodule(synth, name, _options) do
    case name do
      {:__aliases__, _, [name]} ->
        submodule = Submodule.lookup(name)

        if submodule do
          parse_lines(synth, submodule.forms)
        end
      _ -> nil
    end
  end

  defp parse_ugen_options({%Ugen{} = ugen, %Synth{} = synth, []}),
    do: {ugen, synth, []}

  defp parse_ugen_options({
         %Ugen{inputs: inputs} = ugen,
         synth,
         [{_, expression} | rest_options]
       }) do
    {%Synth{} = synth, input} = parse(synth, expression)

    parse_ugen_options({
      %{ugen | inputs: List.flatten(inputs ++ [input])},
      synth,
      rest_options
    })
  end
end
