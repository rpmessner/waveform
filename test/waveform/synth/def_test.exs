defmodule Waveform.Synth.DefTest do
  use ExUnit.Case
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
  @envelope "#{@fixtures}/synths/parsed/envelope.ex"
  @mouse_panner "#{@fixtures}/synths/parsed/mouse_panner.ex"
  @multichannel "#{@fixtures}/synths/parsed/multichannel.ex"
  @multiple_array_inputs "#{@fixtures}/synths/parsed/multiple_array_inputs.ex"
  @saw "#{@fixtures}/synths/parsed/saw.ex"
  @sinosc "#{@fixtures}/synths/parsed/sinosc.ex"

  {array_inputs, _} =
    @array_inputs
    |> File.read!()
    |> Code.eval_string()

  @array_inputs_def array_inputs

  {envelope_def, _} =
    @envelope
    |> File.read!()
    |> Code.eval_string()

  @envelope_def envelope_def

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
        sin_osc = SinOsc.ar(
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
        sin_osc = %SinOsc{freq: midicps(note), mul: 1.0, add: 2.0, phase: 0.0}
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
        #
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
        sin_osc = %SinOsc.ar{freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0}
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

  test "compiles a synth that mixes ar & kr" do
    assert_synthdef(
      @mouse_panner_def,
      defsynth MousePanner, [] do
        %Out{channels: %Pan2.ar{
          in: %WhiteNoise.ar{freq: 0.1},
          pos: %MouseX.kr{minval: -1, maxval: 1}, level: 1}
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

  test "compiles synth with an envelope into %Def" do
    assert_synthdef(
      @envelope_def,
      defsynth EnvelopeDef,
        # midi A4
        note: 69,
        attack: 0,
        decay: 0,
        sustain: 0,
        release: 1,
        attack_level: 1,
        decay_level: -1,
        sustain_level: 1,
        env_curve: 1,
        out_bus: 0 do
        #
        freq = midicps(note)

        sin_osc = %SinOsc.ar{
          freq: freq,
          phase: 0.0,
          mul: 1.0,
          add: 0.0
        }

        envelope =
          Env.envelope(
            attack: attack,
            decay: decay,
            sustain: sustain,
            release: release,
            attack_level: attack_level,
            decay_level: decay_level,
            sustain_level: sustain_level,
            env_curve: env_curve
          )

        envelope = %EnvGen.kr{
          envelope: envelope,
          gate: 1,
          level_scale: 1,
          level_bias: 0,
          time_scale: 1,
          done_action: 2
        }

        %Out{bus: out_bus, channels: sin_osc * envelope}
      end
    )
  end

  test "can handle array outputs" do
    assert_synthdef(
      @array_inputs_def,
      defsynth ArrayInputs, [] do
        sin = %SinOsc.ar{freq: [440, 600], phase: 0, mul: 1, add: 0}
        %Out{channels: sin}
      end
    )
  end

  test "can handle array inputs and outputs" do
    assert_synthdef(
      @array_inputs_def,
      defsynth ArrayInputs, [] do
        [sinl, sinr] = %SinOsc.ar{freq: [440, 600], phase: 0, mul: 1, add: 0}
        %Out{channels: [sinl, sinr]}
      end
    )
  end

  test "can handle multiple array inputs and outputs" do
    assert_synthdef(
      @multiple_array_inputs_def,
      defsynth MultipleArrayInputs, [] do
        [sinl, sinr] = %SinOsc.ar{
          freq: [600, 440],
          phase: [1, 0],
          mul: [4,5],
          add: [3,2]
        }
        %Out{channels: [sinl, sinr]}
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
end
