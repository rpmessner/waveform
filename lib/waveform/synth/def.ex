defmodule Waveform.Synth.Def do
  alias __MODULE__
  alias Waveform.OSC, as: OSC

  defstruct(synthdefs: [])

  defmodule Synth do
    defstruct(
      name: nil,
      constants: [],
      param_values: [],
      param_names: [],
      ugens: [],
      variants: [],
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
    =: 6,
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

  defmacro defsynth({_, _, [name]}, params, do: {:__block__, _, ugen_forms}) do
    compile = Keyword.get(params, :compile)
    compile = if compile == nil, do: true, else: compile
    params = Keyword.delete(params, :compile)

    synthdef = parse_synthdef(name, params, ugen_forms, %Def{})

    if !compile do
      quote do
        unquote(Macro.escape(synthdef))
      end
    else
      compile(synthdef)
    end
  end

  def parse_synthdef(name, params, lines, %Def{synthdefs: synths} = sdef) do
    param_names = Keyword.keys(params) |> Enum.map(&to_string(&1))
    param_values = Keyword.values(params) |> Enum.map(&(&1 + 0.0))
    control_outputs = Enum.map(param_values, &(1 || &1))

    control = %Ugen{name: "Control", rate: 1, special: 0, outputs: control_outputs}

    parameters =
      Keyword.keys(params)
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        {name, %{src: 0, constant_index: i}}
      end)
      |> Enum.into(%{})

    synth =
      parse_line(
        %Synth{
          name: to_string(name) |> String.split() |> List.last(),
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
      # {:=, _, assignment} ->

      {:<-, _, [{output_name, _, nil}, assignment]} ->
        parse_patch(synth, output_name, assignment)

      _ ->
        IO.inspect(line)
        raise "cannot parse line #{Macro.to_string(line)}"
    end
    |> parse_line(rest)
  end

  defp parse_patch(
         %Synth{
           ugens: ugens,
           constants: constants,
           parameters: params,
           assigns: assigns
         } = synth,
         output_name,
         {:%, _, [{_, _, [ugen_name]}, {:%{}, _, options}]}
       ) do
    ugen_opts =
      Map.merge(
        %{name: to_string(ugen_name)},
        Map.get(@ugens, ugen_name)
      )

    ugen = struct(Ugen, ugen_opts)

    {
      ugen,
      %Synth{
        ugens: ugens,
        constants: constants
      } = synth,
      _
    } = parse_ugen({ugen, synth, options})

    index = Enum.count(ugens)
    assigns = Map.put(assigns, output_name, %{ugen: ugen, index: index})

    %{synth | ugens: ugens ++ [ugen], constants: constants, parameters: params, assigns: assigns}
  end

  defp parse_ugen({%Ugen{} = ugen, %Synth{} = synth, []}), do: {ugen, synth, []}

  defp parse_ugen({
         %Ugen{inputs: inputs} = ugen,
         %Synth{constants: consts} = synth,
         [{name, value} | rest_options]
       })
       when is_float(value) do
    parse_ugen({
      %{ugen | inputs: inputs ++ [%Ugen.Input{src: -1, constant_index: Enum.count(consts)}]},
      %{synth | constants: consts ++ [value]},
      rest_options
    })
  end

  defp parse_ugen({
         %Ugen{inputs: inputs} = ugen,
         %Synth{assigns: assigns, parameters: params} = synth,
         [{_name, {assign, _, nil}} = options | rest_options]
       }) do
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

    parse_ugen({
      %{ugen | inputs: inputs ++ [struct(Ugen.Input, options)]},
      synth,
      rest_options
    })
  end

  defp parse_ugen({
         %Ugen{inputs: inputs} = ugen,
         synth,
         [expression | rest_options]
       }) do

    synth = %Synth{ugens: ugens} = parse_expression(synth, expression)

    index = Enum.count(ugens)

    parse_ugen({
      %{ugen | inputs: inputs ++ [%Input{constant_index: 0, src: index - 1}]},
      synth,
      rest_options
    })
  end

  def parse_expression(
        %Synth{ugens: ugens, parameters: params} = synth,
        {name, {operator, _, [{arg_name, _, _}]}}
      ) do
    options = Map.get(params, arg_name)
    special = Map.get(@unary_op_specials, operator)

    operator = %Ugen{
      rate: 1,
      special: special,
      inputs: [struct(Input, options)],
      outputs: [1],
      name: "UnaryOpUgen"
    }

    %{synth | ugens: ugens ++ [operator]}
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
