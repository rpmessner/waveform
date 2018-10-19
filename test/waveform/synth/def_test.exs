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

  @envelope "#{@fixtures}/synths/parsed/envelope.ex"
  @multichannel "#{@fixtures}/synths/parsed/multichannel.ex"
  @saw "#{@fixtures}/synths/parsed/saw.ex"
  @sinosc "#{@fixtures}/synths/parsed/sinosc.ex"

  {sinosc, _} = @sinosc
    |> File.read!()
    |> Code.eval_string()
  @sinosc_def sinosc

  {saw, _} = @saw
    |> File.read!()
    |> Code.eval_string()
  @saw_def saw

  {envelope_def, _} = @envelope
    |> File.read!()
    |> Code.eval_string()
  @envelope_def envelope_def

  {multichannel, _} =
    @multichannel
    |> File.read!()
    |> Code.eval_string()
  @multichannel_def multichannel

  test "compiles a synth def into %Def" do
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
         freq: midicps(note), add: 2.0, phase: 0.0
       }

       %Out{bus: out_bus, channels: sin_osc}
     end
   )
  end

  # test "multi-output synth works" do
  #   assert_synthdef(
  #     @multichannel_def,
  #     defsynth MultiChannel do
  #       saw = %Saw{freq: 440, mul: 1, add: 0}
  #       [left, right] = %Pan2{in: saw, pos: 0, level: 1}
  #       %Out{out_bus: 0, channels: [left, right]}
  #     end
  #   )
  # end
  #
  # test "multi-output synth can be destructured" do
  #   assert_synthdef(
  #     @multichannel_def,
  #     defsynth MultiChannel do
  #       saw = %Saw{freq: 440, mul: 1, add: 0}
  #       [left, right] = %Pan2{in: saw, pos: 0, level: 1}
  #       %Out{out_bus: 0, channels: [left, right]}
  #     end
  #   )
  # end

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
          Util.envelope(
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
end
