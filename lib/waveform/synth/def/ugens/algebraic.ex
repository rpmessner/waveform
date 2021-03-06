defmodule Waveform.Synth.Def.Ugens.Algebraic do
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

  @ugens %{
    BinaryOpUGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [selector: nil, a: nil, b: nil]
    },
    Sum3: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [in0: nil, in1: nil, in2: nil]
    },
    Sum4: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [in0: nil, in1: nil, in2: nil, in3: nil]
    },
    UnaryOpUGen: %{
      defaults: %{rate: 1, special: 0, outputs: [1]},
      arguments: [selector: nil, a: nil]
    }
  }

  def unary_ops do
    @unary_op_specials
  end

  def binary_ops do
    @binary_op_specials
  end

  def definitions do
    @ugens
  end
end
