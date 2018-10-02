defmodule Waveform.Synth.Def do
  alias __MODULE__

  defstruct(synthdefs: [])

  defmodule Synth do
    defstruct(
      name: nil,
      constants: [],
      params: [],
      param_names: [],
      ugens: [],
      variants: []
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

  @ugens %{
    SinOsc: %{rate: 2, special: 0, outputs: [2]},
    Out: %{rate: 2, special: 0}
  }

  @binary_op_specials %{
    absdif: 38,
    add: 0,
    amclip: 40,
    atan2: 22,
    clip2: 42,
    difsqr: 34,
    div: 4,
    excess: 43,
    expon: 25,
    fold2: 44,
    gcd: 18,
    gt: 9,
    gte: 11,
    hypot: 23,
    hypotapx: 24,
    lcm: 17,
    lt: 8,
    lte: 10,
    max: 13,
    modulo: 5,
    min: 12,
    mul: 2,
    pow: 25,
    ring1: 30,
    ring2: 31,
    ring3: 32,
    ring4: 33,
    round: 19,
    scaleneg: 41,
    sqrdif: 37,
    sqrsum: 36,
    sumsqr: 35,
    thresh: 39,
    trunc: 21,
    wrap2: 45
  }

  @unary_op_specials %{
    abs: 5,
    acos: 32,
    ampdb: 22,
    asin: 31,
    atan: 33,
    bilinrand: 40,
    ceil: 8,
    coin: 44,
    cos: 29,
    cosh: 35,
    cpsmidi: 18,
    cpsoct: 24,
    cubed: 13,
    dbamp: 21,
    distort: 42,
    exp: 15,
    floor: 9,
    frac: 10,
    linrand: 39,
    log: 25,
    log10: 27,
    log2: 26,
    midicps: 17,
    midiratio: 19,
    neg: 0,
    octcps: 23,
    ratiomidi: 20,
    rand: 37,
    rand2: 38,
    reciprocal: 16,
    softclip: 43,
    sign: 11,
    sin: 28,
    sinh: 34,
    squared: 12,
    sqrt: 14,
    sum3rand: 41,
    tan: 30,
    tanh: 36
  }

  defmacro defsynth(name, params, do: block) do
    synthdef = build_synthdef(name, params, block)

    quote do
      unquote(Macro.escape(synthdef))
    end
  end

  def build_synthdef({_, _, [name]}, params, {:__block__, _, ugen_forms}) do
    param_names = Keyword.keys(params) |> Enum.map(&to_string(&1))
    param_values = Keyword.values(params) |> Enum.map(&(&1 + 0.0))
    outputs = Enum.map(param_values, &(1 || &1))

    control = %Ugen{name: "Control", rate: 1, special: 0, outputs: outputs}

    parameters =
      Keyword.keys(params)
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        {name, %{src: 0, constant_index: i}}
      end)
      |> Enum.into(%{})

    {ugens, constants, parameters, assigns} =
      ugen_forms
      |> Enum.reduce({[], [], parameters, %{}}, fn line,
                                                   {ugens, constants, parameters, assigns} ->
        parse_line(line, ugens, constants, parameters, assigns)
      end)

    synthdef = %Def{
      synthdefs: [
        %Synth{
          name: to_string(name) |> String.split() |> List.last(),
          constants: constants,
          param_names: param_names,
          params: param_values,
          ugens: [control | ugens]
        }
      ]
    }

  end

  defp parse_line(line, ugens, constants, params, assigns) do
    case line do
      {:<-, _,
       [
         {output, _, nil},
         {:%, _,
          [
            {:__aliases__, _, [name]},
            {:%{}, _, options}
          ]}
       ]} ->
        {_, _, operators, consts, params, assigns, inputs} =
          parse_options({Enum.count(ugens), options, [], [], params, assigns, []})

        ugen_opts =
          Map.merge(
            %{inputs: inputs, name: to_string(name)},
            Map.get(@ugens, name)
          )

        ugen = struct(Ugen, ugen_opts)

        index = Enum.count(ugens) + Enum.count(operators)
        assigns = Map.put(assigns, output, %{ugen: ugen, index: index + 1})

        {ugens ++ operators ++ [ugen], constants ++ consts, params, assigns}

      _ ->
        raise "cannot parse line #{Macro.to_string(line)}"
    end
  end

  defp parse_options({i, [], operators, consts, params, assigns, inputs}),
    do: {i, [], operators, consts, params, assigns, inputs}

  defp parse_options({i, [{name, value} | t], operators, consts, params, assigns, inputs})
       when is_float(value) do
    parse_options({
      i,
      t,
      operators,
      consts ++ [value],
      params,
      assigns,
      inputs ++ [%Ugen.Input{src: -1, constant_index: Enum.count(consts)}]
    })
  end

  defp parse_options(
         {i, [{_name, {assign, _, nil}} = options | t], operators, consts, params, assigns,
          inputs}
       ) do
    saved_assign = Map.get(assigns, assign)
    saved_param = Map.get(params, assign)

    options =
      cond do
        saved_assign ->
          %{src: Map.get(saved_assign, :index), constant_index: 0}

        saved_param ->
          saved_param

        true ->
          raise "unknown constant #{assign} when parsing: #{Macro.to_string(options)}"
      end

    parse_options({
      i,
      t,
      operators,
      consts,
      params,
      assigns,
      inputs ++ [struct(Ugen.Input, options)]
    })
  end

  defp parse_options(
         {i, [{name, {operator, _, [{arg_name, _, _}]}} | t], operators, consts, params, assigns,
          inputs}
       ) do
    options = Map.get(params, arg_name)
    special = Map.get(@unary_op_specials, operator)

    operator = %Ugen{
      rate: 1,
      special: special,
      inputs: [struct(Ugen.Input, options)],
      outputs: [1],
      name: "UnaryOpUgen"
    }

    parse_options(
      {i, t, operators ++ [operator], consts, params, assigns,
       inputs ++ [struct(Ugen.Input, %{constant_index: 0, src: i + 1})]}
    )
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
  defp num_params(%Synth{params: params}, 2), do: <<Enum.count(params)::size(32)>>
  defp num_params(%Synth{params: params}, 1), do: <<Enum.count(params)::size(16)>>

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

  defp definitions(%Def{synthdefs: [synthdefs | rest]}, version) do
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
    Enum.reduce(inputs, "", fn %Ugen.Input{src: src, constant_index: constant_index}, acc ->
      acc <> <<src::size(32)>> <> <<constant_index::size(32)>>
    end)
  end

  defp inputs(%Ugen{inputs: inputs}, 1) do
    Enum.reduce(inputs, "", fn %Ugen.Input{src: src, constant_index: constant_index}, acc ->
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

  defp parameters(%Synth{params: params}) do
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
