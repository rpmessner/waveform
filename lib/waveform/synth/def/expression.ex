defmodule Waveform.Synth.Def.Expression do
  alias Waveform.Synth.Def.Synth, as: Synth
  alias Waveform.Synth.Def.Ugen, as: Ugen
  alias Waveform.Synth.Def.Util, as: Util
  alias Waveform.Synth.Def.Ugen.Input, as: Input

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

end
