defmodule Waveform.Synth.Def do
  alias Waveform.Synth.Def.Submodule, as: Submodule
  alias Waveform.Synth.Manager, as: Manager
  alias Waveform.OSC, as: OSC

  alias __MODULE__

  defstruct(synthdefs: [])

  defmodule Synth do
    defstruct(
      # outputted to .synthdef
      name: nil,
      constants: [],
      param_values: [],
      param_names: [],
      ugens: [],
      variants: [],

      # internal state
      parameters: %{},
      assigns: %{}
    )
  end

  defmodule Ugen do
    defstruct(
      name: nil,
      rate: nil,
      special: nil,
      inputs: [],
      outputs: []
    )
  end

  defmodule Ugen.Input do
    defstruct(
      src: nil,
      constant_index: nil
    )
  end

  alias Ugen.Input, as: Input

  @ugens %{
    SinOsc: %{rate: 2, special: 0, outputs: [2]},
    Saw: %{rate: 2, special: 0, outputs: [2]},
    Out: %{rate: 2, special: 0}
  }

  @binary_op_specials %{
    add: 0,
    +: 0,
    sub: 1,
    -: 1,
    mul: 2,
    *: 2,
    div: 4,
    /: 4,
    modulo: 5,
    %: 5,
    eq: 6,
    ==: 6,
    lt: 8,
    <: 8,
    gt: 9,
    >: 9,
    lte: 10,
    <=: 10,
    gte: 11,
    >=: 11,
    min: 12,
    max: 13,
    and: 14,
    or: 15,
    xor: 16,
    lcm: 17,
    gcd: 18,
    round: 19,
    roundup: 20,
    trunc: 21,
    atan2: 22,
    hypot: 23,
    hypotapx: 24,
    pow: 25,
    expon: 25,
    ^: 25,
    ring1: 30,
    ring2: 31,
    ring3: 32,
    ring4: 33,
    difsqr: 34,
    sumsqr: 35,
    sqrsum: 36,
    sqrdif: 37,
    absdif: 38,
    thresh: 39,
    amclip: 40,
    scaleneg: 41,
    clip2: 42,
    excess: 43,
    fold2: 44,
    wrap2: 45
  }

  @unary_op_specials %{
    neg: 0,
    -: 0,
    notpos: 1,
    abs: 5,
    ceil: 8,
    floor: 9,
    frac: 10,
    sign: 11,
    squared: 12,
    cubed: 13,
    sqrt: 14,
    exp: 15,
    reciprocal: 16,
    midicps: 17,
    to_htz: 17,
    cpsmidi: 18,
    midiratio: 19,
    ratiomidi: 20,
    dbamp: 21,
    ampdb: 22,
    octcps: 23,
    cpsoct: 24,
    log: 25,
    log2: 26,
    log10: 27,
    sin: 28,
    cos: 29,
    tan: 30,
    asin: 31,
    acos: 32,
    atan: 33,
    sinh: 34,
    cosh: 35,
    tanh: 36,
    rand: 37,
    rand2: 38,
    linrand: 39,
    bilinrand: 40,
    sum3rand: 41,
    distort: 42,
    softclip: 43,
    coin: 44,
    silence: 46,
    thru: 47,
    rectWindow: 48,
    hanWindow: 49,
    welWindow: 50,
    triWindow: 51,
    ramp: 52,
    scurve: 53
  }

  defmacro defsubmodule({_, _, [name]}, params, do: {:__block__, _, submodule_forms}) do
    Submodule.define(name, params, submodule_forms)
  end

  defmacro defsynth({_, _, [name]}, params, do: {:__block__, _, ugen_forms}) do
    name = parse_synthdef_name(name)

    %Def{} = synthdef = parse_synthdef(name, params, ugen_forms, %Def{})


    compiled = compile(synthdef)
    Manager.create_synth(name, compiled)

    quote do
      { unquote(Macro.escape(synthdef)), unquote(compiled) }
    end
  end

  def parse_synthdef_name(name) do
    to_string(name) |> String.split() |> List.last() |> Recase.to_kebab()
  end

  def parse_synthdef(name, params, lines, %Def{synthdefs: synths} = sdef) do
    param_names = Keyword.keys(params) |> Enum.map(&to_string(&1))
    param_values = Keyword.values(params) |> Enum.map(&(&1 + 0.0))
    control_outputs = Enum.map(param_values, fn _ -> 1 end)

    control = %Ugen{name: "Control", rate: 1, special: 0, outputs: control_outputs}

    parameters =
      Keyword.keys(params)
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        {name, %Input{src: 0, constant_index: i}}
      end)
      |> Enum.into(%{})

    synth =
      parse_line(
        %Synth{
          name: name,
          constants: [],
          param_names: param_names,
          param_values: param_values,
          parameters: parameters,
          assigns: %{},
          ugens: [control]
        },
        lines
      )

    %{sdef | synthdefs: [synth | synths]}
  end

  defp parse_line(%Synth{} = synth, []), do: synth

  defp parse_line(%Synth{} = synth, [line | rest]) do
    case line do
      {op, _, [{assign_name, _, nil}, expression]} when op in [:<-, :=] ->
        parse_assignment(synth, assign_name, expression)

      _ ->
        raise "cannot parse line #{Macro.to_string(line)}"
    end
    |> parse_line(rest)
  end

  defp parse_assignment(%Synth{} = synth, output_name, expression) do
    {%Synth{assigns: assigns} = synth, input} =
      case expression do
        {:%, _, _} = ugen ->
          synth = parse_ugen(synth, ugen)

          {
            synth,
            %Input{src: Enum.count(synth.ugens) - 1, constant_index: 0}
          }

        _ ->
          parse_expression(synth, expression)
      end

    assigns = Map.put(assigns, output_name, input)

    %{synth | assigns: assigns}
  end

  defp parse_ugen_name(ugen_name) do
    {ugen_name, ugen_opts} = case ugen_name do
      {_, _, [name]} -> {name, Map.get(@ugens, name) || %{}}
      _ -> raise "can't parse #{Macro.to_string(ugen_name)}"
    end


    # unless ugen_opts do
    #   raise "unknown ugen: %#{to_string(ugen_name)}{}"
    # end

    ugen_opts =
      Map.merge(
        %{name: to_string(ugen_name)},
        ugen_opts
      )

    ugen = struct(Ugen, ugen_opts)
  end

  defp parse_ugen(
         %Synth{} = synth,
         {:%, _,
          [
            ugen_name,
            {:%{}, _, options}
          ]} = ugen
       ) do

    ugen = parse_ugen_name(ugen_name)

    {
      ugen,
      %Synth{ugens: ugens} = synth,
      _
    } = parse_ugen_options({ugen, synth, options})

    %{synth | ugens: ugens ++ [ugen]}
  end

  defp parse_ugen_options({%Ugen{} = ugen, %Synth{} = synth, []}), do: {ugen, synth, []}

  defp parse_ugen_options({
         %Ugen{inputs: inputs} = ugen,
         synth,
         [{_, expression} | rest_options]
       }) do
    {%Synth{} = synth, input} = parse_expression(synth, expression)

    parse_ugen_options({
      %{ugen | inputs: inputs ++ [input]},
      synth,
      rest_options
    })
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

  defp parse_expression(
         %Synth{} = synth,
         {:if, _, [condition, [do: arg1, else: arg2]]}
       ) do
    {synth, input1} = parse_expression(synth, condition)
    {synth, input2} = parse_expression(synth, arg1)
    {synth, input3} = parse_expression(synth, arg2)

    operator = %Ugen{
      rate: 1,
      special: 0,
      inputs: [input1, input2, input3],
      outputs: [1],
      name: "Select"
    }

    {
      %{synth | ugens: synth.ugens ++ [operator]},
      %Input{src: Enum.count(synth.ugens), constant_index: 0}
    }
  end

  defp parse_expression(
         %Synth{ugens: ugens} = synth,
         {operator, _, [arg1, arg2]} = expression
       ) do
    special = Map.get(@binary_op_specials, operator)

    if special == nil do
      raise "unknown operator #{operator} when parsing #{Macro.to_string(expression)}"
    end

    {synth, input1} = parse_expression(synth, arg1)
    {synth, input2} = parse_expression(synth, arg2)

    # IO.inspect({Macro.to_string(expression), expression, input1, input2})

    operator = %Ugen{
      rate: 1,
      special: special,
      inputs: [input1, input2],
      outputs: [1],
      name: "BinaryOpUGen"
    }

    {
      %{synth | ugens: ugens ++ [operator]},
      %Input{src: Enum.count(ugens), constant_index: 0}
    }
  end

  defp parse_expression(
         %Synth{ugens: ugens} = synth,
         {operator, _, [arg]} = expression
       ) do
    special = Map.get(@unary_op_specials, operator)

    if special == nil do
      raise "unknown operator #{operator} when parsing #{Macro.to_string(expression)}"
    end

    {synth, input} = parse_expression(synth, arg)

    operator = %Ugen{
      rate: 1,
      special: special,
      inputs: [input],
      outputs: [1],
      name: "UnaryOpUGen"
    }

    {
      %{synth | ugens: ugens ++ [operator]},
      %Input{src: Enum.count(ugens), constant_index: 0}
    }
  end

  defp parse_expression(%Synth{} = synth, {_, _, nil} = value) do
    expression_input(synth, value)
  end

  defp parse_expression(%Synth{} = synth, value)
       when is_float(value) or is_integer(value) do
    expression_input(synth, value)
  end

  defp parse_expression(%Synth{}, value) do
    raise "Cannot parse expression #{Macro.to_string(value)}"
  end

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
