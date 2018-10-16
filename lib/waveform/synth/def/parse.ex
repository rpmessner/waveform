defmodule Waveform.Synth.Def.Parse do
  alias Waveform.Synth.Def.Submodule, as: Submodule
  alias Waveform.Synth.Def.Synth, as: Synth
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Ugen.Input, as: Input
  alias Waveform.Synth.Def.Ugens, as: Ugens
  alias Waveform.Synth.Def.Util, as: Util

  @ugens Ugens.definitions()

  @unary_op_specials Ugens.BasicOps.unary_ops()
  @binary_op_specials Ugens.BasicOps.binary_ops()

  @kr %{outputs: [1], rate: 1, special: 0}
  @ar %{outputs: [2], rate: 2, special: 0}

  def parse(%Synth{} = synth, definition), do: parse({synth, nil}, definition)

  def parse({%Synth{} = synth, i}, []), do: {synth, i}

  # parse lines
  def parse({%Synth{} = synth, i}, [line | rest]) do
    parse({synth, i}, line) |> parse(rest)
  end

  # parse assignment
  def parse(
        {%Synth{} = synth, i},
        {op, _, [{output_name, _, nil}, expression]}
      )
      when op in [:<-, :=] do
    {%Synth{assigns: assigns} = synth, input} = parse({synth, i}, expression)

    assigns = Map.put(assigns, output_name, input)

    {%{synth | assigns: assigns}, input}
  end

  # parse ugen/submodule
  def parse(
        {%Synth{} = synth, i},
        {:%, _,
         [
           ugen_name,
           {:%{}, _, options}
         ]} = ugen
      ) do

    {synth, _i} =
      case parse_submodule({synth, i}, ugen_name, options) do
        nil ->

          {ugen, %{arguments: arguments}} = parse_ugen(ugen_name)

          options =
            Enum.sort_by(options, fn {key, _value} ->
              Enum.find_index(Keyword.keys(arguments), &(&1 == key))
            end)

          {
            ugen,
            {%Synth{ugens: ugens} = synth, i},
            _
          } = parse_ugen_options({ugen, {synth, i}, options})

          {%{synth | ugens: ugens ++ [ugen]}, i}

        {synth, i} ->
          {synth, i}
      end

    src = Enum.count(synth.ugens) - 1

    inputs = List.last(synth.ugens).outputs
             |> Enum.with_index()
             |> Enum.map(fn {_output, i} ->
               %Input{src: src, constant_index: i}
             end)

    { synth, inputs }
  end

  # parse util fn
  def parse(
        {%Synth{} = synth, i},
        {{:., _, [{:__aliases__, _, [:Util]}, function]}, _, [options]}
      ) do
    apply(Util, function, [{synth, i}, options])
  end

  # parse if/else
  def parse(
        {%Synth{} = synth, i},
        {:if, _, [condition, [do: arg1, else: arg2]]}
      ) do
    {synth, input1} = parse({synth, i}, condition)
    {synth, input2} = parse({synth, i}, arg1)
    {synth, input3} = parse({synth, i}, arg2)

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

  # parse binary op
  def parse(
        {%Synth{ugens: ugens} = synth, i},
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

    {
      %{synth | ugens: ugens ++ [operator]},
      [%Input{src: Enum.count(ugens), constant_index: 0}]
    }
  end

  # parse unary op
  def parse(
        {%Synth{ugens: ugens} = synth, i},
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
    {
      %{synth | constants: constants ++ [arg + 0.0]},
      [%Input{src: -1, constant_index: Enum.count(constants)}]
    }
  end

  def parse({%Synth{}, _i}, value) do
    raise "Cannot parse expression #{Macro.to_string(value)}"
  end

  defp parse_ugen(ugen_name) do
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

  defp parse_submodule({synth, i}, name, _options) do
    case name do
      {:__aliases__, _, [name]} ->
        submodule = Submodule.lookup(name)

        if submodule do
          parse({synth, i}, submodule.forms)
        end

      _ ->
        nil
    end
  end

  defp parse_ugen_options(
    {%Ugen{} = ugen, {%Synth{} = synth, i}, []}
  ), do: {ugen, {synth, i}, []}

  defp parse_ugen_options({
         %Ugen{inputs: inputs} = ugen,
         {synth, i},
         [{_, expression} | rest_options]
       }) do

    {%Synth{} = synth, input} = parse({synth, i}, expression)

    parse_ugen_options({
      %{ugen | inputs: List.flatten(inputs ++ [input])},
      {synth, input},
      rest_options
    })
  end

  defp lookup_rate(_synth, %Input{src: -1}), do: 1
  defp lookup_rate(_synth, []), do: 2
  defp lookup_rate(%Synth{} = s, [%Input{} = i]), do: lookup_rate(s, i)

  defp lookup_rate(%Synth{ugens: ugens}, %Input{src: sidx, constant_index: cidx}) do
    Enum.at(ugens, sidx).outputs |> Enum.at(cidx)
  end

  defp build_ugen(name, base), do: build_ugen(name, base, priority: :low)

  defp build_ugen(name, base, priority: priority) do
    ugen_def = Map.get(@ugens, name)

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

    {struct(Ugen, ugen), ugen_def}
  end
end
