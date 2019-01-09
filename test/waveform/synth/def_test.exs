defmodule Waveform.Synth.DefTest do
  use ExUnit.Case

  require Waveform.Assertions
  import Waveform.Assertions

  alias Waveform.Synth.Def, as: Subject

  require Subject
  import Subject

  @fixtures __ENV__.file
            |> Path.dirname()
            |> Path.join("../../fixtures/")
            |> to_charlist

  @array_inputs "#{@fixtures}/synths/parsed/array_inputs.ex"
  @array_inputs_binary_op "#{@fixtures}/synths/parsed/array_inputs_binary_op.ex"
  @array_env "#{@fixtures}/synths/parsed/array_env.ex"
  @envelope1 "#{@fixtures}/synths/parsed/envelope1.ex"
  @envelope2 "#{@fixtures}/synths/parsed/envelope2.ex"
  @envelope3 "#{@fixtures}/synths/parsed/envelope3.ex"
  @mouse_panner "#{@fixtures}/synths/parsed/mouse_panner.ex"
  @multichannel "#{@fixtures}/synths/parsed/multichannel.ex"
  @multiple_array_inputs "#{@fixtures}/synths/parsed/multiple_array_inputs.ex"
  @range "#{@fixtures}/synths/parsed/range.ex"
  @saw "#{@fixtures}/synths/parsed/saw.ex"
  @sinosc "#{@fixtures}/synths/parsed/sinosc.ex"
  @apad_mh "#{@fixtures}/synths/parsed/apad_mh.ex"

  {apad_mh, _} =
    @apad_mh
    |> File.read!()
    |> Code.eval_string()

  @apad_mh_def apad_mh

  {array_inputs, _} =
    @array_inputs
    |> File.read!()
    |> Code.eval_string()

  @array_inputs_def array_inputs

  {array_inputs_binary_op, _} =
    @array_inputs_binary_op
    |> File.read!()
    |> Code.eval_string()

  @array_inputs_binary_op_def array_inputs_binary_op

  {array_env, _} =
    @array_env
    |> File.read!()
    |> Code.eval_string()

  @array_env_def array_env

  {envelope1_def, _} =
    @envelope1
    |> File.read!()
    |> Code.eval_string()

  @envelope1_def envelope1_def

  {envelope2_def, _} =
    @envelope2
    |> File.read!()
    |> Code.eval_string()

  @envelope2_def envelope2_def

  {envelope3_def, _} =
    @envelope3
    |> File.read!()
    |> Code.eval_string()

  @envelope3_def envelope3_def

  {mouse_panner, _} =
    @mouse_panner
    |> File.read!()
    |> Code.eval_string()

  @mouse_panner_def mouse_panner

  {multichannel, _} =
    @multichannel
    |> File.read!()
    |> Code.eval_string()

  @multichannel_def multichannel

  {multiple_array_inputs, _} =
    @multiple_array_inputs
    |> File.read!()
    |> Code.eval_string()

  @multiple_array_inputs_def multiple_array_inputs

  {range, _} =
    @range
    |> File.read!()
    |> Code.eval_string()

  @range_def range

  {saw, _} =
    @saw
    |> File.read!()
    |> Code.eval_string()

  @saw_def saw

  {sinosc, _} =
    @sinosc
    |> File.read!()
    |> Code.eval_string()

  @sinosc_def sinosc

  test "compiles a synth def into %Def with struct syntax" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        sin_osc = %SinOsc{
          freq: midicps(note),
          phase: 0.0,
          mul: 1.0,
          add: 2.0
        }

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "compiles a synth def into %Def with module syntax" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        sin_osc =
          SinOsc.ar(
            freq: midicps(note),
            phase: 0.0,
            mul: 1.0,
            add: 2.0
          )

        Out.ar(bus: out_bus, channels: sin_osc)
      end
    )
  end

  test "ugen args are in correct order when compiled into %Def" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        sin_osc = SinOsc.ar(freq: midicps(note), mul: 1.0, add: 2.0, phase: 0.0)
        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "unary op dot syntax" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        sin_osc = %SinOsc{freq: note.midicps(), mul: 1.0, add: 2.0, phase: 0.0}
        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "|> syntax works with unary op" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        freq = note |> midicps

        sin_osc = %SinOsc{freq: freq, mul: 1.0, add: 2.0, phase: 0.0}

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "|> syntax works with binary op" do
    assert_synthdef(
      @saw_def,
      defsynth SawDef,
        # midi A4
        note: 69,
        out_bus: 0,
        foo: 0,
        bar: 0 do
        #
        freq = midicps(note)
        freq2 = freq |> mul(2.0)

        sawfreq = if foo > 0.5, do: freq, else: freq2

        saw = %Saw{
          freq: freq,
          mul: 1.0,
          add: 2.0
        }

        %Out{bus: out_bus, channels: saw}
      end
    )
  end

  test "|> syntax works with ugen" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc =
          midicps(note)
          |> %SinOsc{mul: 1.0, add: 2.0, phase: 0.0}

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "|> syntax for keyword argument works with tuple" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc =
          {:add, 2.0}
          |> %SinOsc{freq: midicps(note), mul: 1.0, phase: 0.0}

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "|> syntax for keyword argument works with map" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc =
          %{add: 2.0}
          |> %SinOsc{freq: midicps(note), mul: 1.0, phase: 0.0}

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "ugen meta in /synth/def/ugens default arguments work" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        # mul not provided
        sin_osc = %SinOsc{
          freq: midicps(note),
          add: 2.0,
          phase: 0.0
        }

        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "multi-output synth works" do
    assert_synthdef(
      @multichannel_def,
      defsynth MultiChannel, [] do
        saw = %Saw{freq: 440, mul: 1, add: 0}
        outputs = %Pan2{in: saw, pos: 0, level: 1}
        %Out{bus: 0, channels: outputs}
      end
    )
  end

  test "compiles ar/kr syntax into %Def" do
    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        #
        sin_osc = SinOsc.ar(freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0)
        %Out{bus: out_bus, channels: sin_osc}
      end
    )
  end

  test "compiles synth with submodules into %Def" do
    defsubmodule AwesomeSubmodule, note: 69 do
      freq = midicps(note)
      %SinOsc{freq: freq, phase: 0.0, mul: 1.0, add: 2.0}
    end

    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef, note: 69, out_bus: 0 do
        bar = %AwesomeSubmodule{note: note}
        %Out{bus: out_bus, channels: bar}
      end
    )
  end

  test "submodule error if doesn't exist" do
    assert_compile_time_raise(RuntimeError, "Unknown ugen or submodule UndefinedSubmodule", fn ->
      alias Waveform.Synth.Def, as: Subject
      require Subject
      import Subject

      defsynth UnknownSubmoduleDef, [] do
        bar = %UndefinedSubmodule{}
        %Out{channels: bar}
      end
    end)
  end

  test "submodule variable assignment is hygenic" do
    defsubmodule AwesomeSubmodule, note: 69 do
      foo = note
      %SinOsc{freq: foo, phase: 0.0, mul: 1.0, add: 2.0}
    end

    assert_synthdef(
      @sinosc_def,
      defsynth SinOscDef, note: 69, out_bus: 0 do
        foo = out_bus
        freq = midicps(note)
        bar = %AwesomeSubmodule{note: freq}
        %Out{bus: foo, channels: bar}
      end
    )
  end

  test "submodule variable scoping behaves correctly" do
    defsubmodule AwesomeSubmodule, foo: nil do
      %SinOsc{freq: freq, phase: 0.0, mul: 1.0, add: 2.0}
    end

    assert_compile_time_raise(RuntimeError, "unknown variable \"freq\"", fn ->
      alias Waveform.Synth.Def, as: Subject
      require Subject
      import Subject

      defsynth SinOscDef, note: 69, out_bus: 0 do
        freq = midicps(note)
        bar = %AwesomeSubmodule{}
        %Out{bus: out_bus, channels: bar}
      end
    end)
  end

  test "submodules raise error when used incorrectly" do
    defsubmodule AwesomeSubmodule, note: 69, bar: nil do
      freq = midicps(note)
      %SinOsc{freq: freq, phase: 0.0, mul: 1.0, add: 2.0}
    end

    assert_compile_time_raise(RuntimeError, "unknown submodule argument \"foo\"", fn ->
      alias Waveform.Synth.Def, as: Subject
      require Subject
      import Subject

      defsynth SinOscDef, note: 69, out_bus: 0 do
        bar = %AwesomeSubmodule{foo: 0, note: note}
        Out.ar(bus: out_bus, channels: bar)
      end
    end)

    assert_compile_time_raise(RuntimeError, "required argument missing \"note\"", fn ->
      alias Waveform.Synth.Def, as: Subject
      require Subject
      import Subject

      defsynth SinOscDef, note: 69, out_bus: 0 do
        bar = %AwesomeSubmodule{bar: 0}
        %Out{bus: out_bus, channels: bar}
      end
    end)
  end

  test "compiles a synth that mixes ar & kr" do
    assert_synthdef(
      @mouse_panner_def,
      defsynth MousePanner, [] do
        %Out{
          channels:
            Pan2.ar(
              in: WhiteNoise.ar(freq: 0.1),
              pos: MouseX.kr(minval: -1, maxval: 1),
              level: 1
            )
        }
      end
    )
  end

  test "compiles a more complex synth def into %Def" do
    assert_synthdef(
      @saw_def,
      defsynth SawDef,
        # midi A4
        note: 69,
        out_bus: 0,
        foo: 0,
        bar: 0 do
        #
        freq = midicps(note)
        freq2 = freq * 2.0

        sawfreq = if foo > 0.5, do: freq, else: freq2

        saw = %Saw{
          freq: freq,
          mul: 1.0,
          add: 2.0
        }

        %Out{bus: out_bus, channels: saw}
      end
    )
  end

  test "compiles synth with an adsr envelope into %Def" do
    assert_synthdef(
      @envelope1_def,
      defsynth Env1, [] do
        sin_osc = SinOsc.ar(freq: 550, phase: 7)

        env_gen =
          EnvGen.kr(
            gate: 24,
            level_scale: 25,
            level_bias: 26,
            time_scale: 27,
            done_action: 8,
            envelope:
              Env.adsr(
                attack_time: 0.01,
                decay_time: 0.02,
                sustain_level: 0.03,
                release_time: 0.04
              )
          )

        Out.ar(
          bus: 999,
          channels: sin_osc * env_gen
        )
      end
    )
  end

  test "compiles synth with generic envelope into %Def" do
    assert_synthdef(
      @envelope2_def,
      defsynth Env2, [] do
        sin_osc = SinOsc.ar(freq: 550, phase: 7)

        env_gen =
          EnvGen.kr(
            # 1
            gate: 24,
            # 1
            level_scale: 25,
            # 0
            level_bias: 26,
            # 1
            time_scale: 27,
            done_action: 8,
            envelope:
              Env.new(
                [11, 12, 13, 14],
                [21, 22, 23],
                [-1, -2, -3],
                40,
                41
              )
          )

        Out.ar(bus: 999, channels: sin_osc * env_gen)
      end
    )
  end

  test "compiles synth with generic envelope with defaults into %Def" do
    assert_synthdef(
      @envelope3_def,
      defsynth Env3, [] do
        sin_osc = SinOsc.ar(freq: 550, phase: 7)

        env_gen =
          EnvGen.kr(
            done_action: 8,
            envelope:
              Env.new(
                [11, 12, 13, 14],
                [21, 22, 23],
                :welch
              )
          )

        Out.ar(bus: 999, channels: sin_osc * env_gen)
      end
    )
  end

  test "done_action can use module syntax" do
    assert_synthdef(
      @array_env_def,
      defsynth ArrayEnv, [] do
        env =
          EnvGen.kr(
            gate: 0.8,
            level_scale: 1,
            done_action: Done.free_self(),
            envelope:
              Env.adsr(
                attack_time: 0.4,
                decay_time: 0.5,
                sustain_level: 0.6,
                release_time: 0.7
              )
          )

        Out.ar(bus: 0, channels: SinOsc.ar(freq: [440, 880]) * env)
      end
    )
  end

  test "can multiply by an env with a split Ugen" do
    assert_synthdef(
      @array_env_def,
      defsynth ArrayEnv, [] do
        env =
          EnvGen.kr(
            gate: 0.8,
            level_scale: 1,
            done_action: Done.free_self(),
            envelope:
              Env.adsr(
                attack_time: 0.4,
                decay_time: 0.5,
                sustain_level: 0.6,
                release_time: 0.7
              )
          )

        Out.ar(bus: 0, channels: SinOsc.ar(freq: [440, 880]) * env)
      end
    )
  end

  test "can handle array outputs" do
    assert_synthdef(
      @array_inputs_def,
      defsynth ArrayInputs, [] do
        sin = SinOsc.ar(freq: [440, 600], phase: 0, mul: 1, add: 0)
        %Out{channels: sin}
      end
    )
  end

  test "can handle array inputs and outputs" do
    assert_synthdef(
      @array_inputs_def,
      defsynth ArrayInputs, [] do
        [sinl, sinr] = SinOsc.ar(freq: [440, 600], phase: 0, mul: 1, add: 0)
        %Out{channels: [sinl, sinr]}
      end
    )
  end

  test "can handle multiple array inputs and outputs" do
    assert_synthdef(
      @multiple_array_inputs_def,
      defsynth MultipleArrayInputs, [] do
        [sinl, sinr] =
          SinOsc.ar(
            freq: [600, 440],
            phase: [1, 0],
            mul: [4, 5],
            add: [3, 2]
          )

        %Out{channels: [sinl, sinr]}
      end
    )
  end

  test "ugen with range" do
    assert_synthdef(
      @apad_mh_def,
      defsynth ApadMh, [] do
        mod1 = Saw.kr(freq: 6).range(999..777)
        [sigl, sigr] = SinOsc.ar(freq: [440, mod1], phase: 0)
        Out.ar(bus: 0, channels: [distort(sigl), distort(sigr)])
      end
    )

    assert_synthdef(
      @apad_mh_def,
      defsynth ApadMh, [] do
        mod1 = Saw.kr(freq: 6).range(999..777)
        [sigl, sigr] = distort(SinOsc.ar(freq: [440, mod1], phase: 0))
        Out.ar(bus: 0, channels: [sigl, sigr])
      end
    )

    assert_synthdef(
      @apad_mh_def,
      defsynth ApadMh, [] do
        mod1 = Saw.kr(freq: 6).range(999, 777)
        [sigl, sigr] = distort(SinOsc.ar(freq: [440, mod1], phase: 0))
        Out.ar(bus: 0, channels: [sigl, sigr])
      end
    )
  end

  test "array input ugen with binary op" do
    assert_synthdef(
      @array_inputs_binary_op_def,
      defsynth ArrayInputsBinaryOp, [] do
        Out.ar(bus: 0, channels: mul(SinOsc.ar(freq: [440, 880, 2640], phase: 0), 2))
      end
    )

    assert_synthdef(
      @array_inputs_binary_op_def,
      defsynth ArrayInputsBinaryOp, [] do
        Out.ar(bus: 0, channels: SinOsc.ar(freq: [440, 880, 2640]) * 2)
      end
    )
  end

  test "multi-output synth can be destructured" do
    assert_synthdef(
      @multichannel_def,
      defsynth MultiChannel, [] do
        saw = %Saw{freq: 440, mul: 1, add: 0}
        [left, right] = %Pan2{in: saw, pos: 0, level: 1}
        %Out{bus: 0, channels: [left, right]}
      end
    )
  end

  test "random numbers" do
    {
      %Subject{
        synthdefs: [%Subject.Synth{constants: [c1, _c2]}]
      },
      _
    } =
      defsynth Rrandom, [] do
        SinOsc.ar(freq: rrand(0, 1))
      end

    assert c1 > 0
    assert c1 < 1

    {
      %Subject{
        synthdefs: [%Subject.Synth{constants: [c1, _c2]}]
      },
      _
    } =
      defsynth Rrandom, [] do
        SinOsc.ar(freq: rrand(10, 20))
      end

    assert c1 > 10
    assert c1 < 20
  end

  test "range with arg" do
    # SynthDef(\range, { arg freq = 440;
    # Out.ar(0, SinOsc.ar(freq).range(freq * 0.99, freq * 1.01)); })
    assert_synthdef(
      @range_def,
      defsynth Range, freq: 440 do
        Out.ar(
          bus: 0,
          channels: SinOsc.ar(freq: freq).range(freq * 0.99, freq * 1.01)
        )
      end
    )
  end

  test "repeat syntax" do
    assert_synthdef(
      %Subject{
        synthdefs: [
          %Subject.Synth{
            name: "repeat",
            constants: [440.0, 0.0],
            ugens: [
              %Subject.Ugen{
                name: "SinOsc",
                rate: 2,
                outputs: [2],
                inputs: [
                  %Subject.Ugen.Input{
                    src: -1,
                    constant_index: 0
                  },
                  %Subject.Ugen.Input{
                    src: -1,
                    constant_index: 1
                  }
                ]
              },
              %Subject.Ugen{
                name: "SinOsc",
                rate: 2,
                outputs: [2],
                inputs: [
                  %Subject.Ugen.Input{
                    src: -1,
                    constant_index: 0
                  },
                  %Subject.Ugen.Input{
                    src: -1,
                    constant_index: 1
                  }
                ]
              },
              %Subject.Ugen{
                name: "Out",
                rate: 2,
                outputs: [],
                inputs: [
                  %Subject.Ugen.Input{
                    src: -1,
                    constant_index: 1
                  },
                  %Subject.Ugen.Input{
                    src: 0,
                    constant_index: 0
                  },
                  %Subject.Ugen.Input{
                    src: 1,
                    constant_index: 0
                  }
                ]
              }
            ]
          }
        ]
      },
      defsynth Repeat, [] do
        sines = (SinOsc.ar(freq: 440) | 2)
        Out.ar(channels: sines)
      end
    )
  end

  test "can build an asr Env" do
    assert_synthdef(
      %Subject{
        synthdefs: [
          %Subject.Synth{
            name: "atari",
            constants: [
              1.0,
              0.0,
              2.0,
              -99.0,
              0.01,
              5.0,
              -4.0,
              0.05
            ],
            ugens: [
              %Subject.Ugen{
                name: "EnvGen",
                rate: 1,
                inputs: [
                  %Subject.Ugen.Input{src: -1, constant_index: 0},
                  %Subject.Ugen.Input{src: -1, constant_index: 0},
                  %Subject.Ugen.Input{src: -1, constant_index: 1},
                  %Subject.Ugen.Input{src: -1, constant_index: 0},
                  %Subject.Ugen.Input{src: -1, constant_index: 2},
                  %Subject.Ugen.Input{src: -1, constant_index: 1},
                  %Subject.Ugen.Input{src: -1, constant_index: 2},
                  %Subject.Ugen.Input{src: -1, constant_index: 0},
                  %Subject.Ugen.Input{src: -1, constant_index: 3},
                  %Subject.Ugen.Input{src: -1, constant_index: 0},
                  %Subject.Ugen.Input{src: -1, constant_index: 4},
                  %Subject.Ugen.Input{src: -1, constant_index: 5},
                  %Subject.Ugen.Input{src: -1, constant_index: 6},
                  %Subject.Ugen.Input{src: -1, constant_index: 1},
                  %Subject.Ugen.Input{src: -1, constant_index: 7},
                  %Subject.Ugen.Input{src: -1, constant_index: 5},
                  %Subject.Ugen.Input{src: -1, constant_index: 6}
                ],
                outputs: [1]
              }
            ]
          }
        ]
      },
      defsynth Atari, [] do
        EnvGen.kr(
          gate: 1,
          done_action: Done.free_self(),
          envelope:
            Env.asr(
              attack_time: 0.01,
              sustain_level: 1,
              release_time: 0.05
            )
        )
      end
    )
  end
end
