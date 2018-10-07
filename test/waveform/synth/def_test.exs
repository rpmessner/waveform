defmodule Waveform.Synth.DefTest do
  use ExUnit.Case
  alias Waveform.Synth.Def, as: Subject

  require Subject
  import Subject

  @fixtures __ENV__.file
            |> Path.dirname()
            |> Path.join("../../fixtures/")
            |> to_charlist

  @synthdef "#{@fixtures}/synths/compiled/beep.scsyndef"
  @synthdata "#{@fixtures}/synths/compiled/beep.ex"

  test "compiles a synth def ast into binary" do
    {:ok, filepid} = File.open(@synthdef)

    result = IO.binread(filepid, :all)

    {code, _} =
      @synthdata
      |> File.read!()
      |> Code.eval_string()

    compiled = Subject.compile(code)

    {:ok, counter} = Agent.start(fn -> 0 end)

    chunk_size = 8

    expected_chunks =
      for <<expected::size(chunk_size) <- result>>, do: <<expected::size(chunk_size)>>

    actual_chunks = for <<actual::size(chunk_size) <- compiled>>, do: <<actual::size(chunk_size)>>

    Enum.map(Enum.zip(expected_chunks, actual_chunks), fn {expected_byte, actual_byte} ->
      idx = Agent.get(counter, fn state -> state end)

      assert {^idx, ^expected_byte} = {idx, actual_byte}

      Agent.update(counter, &(&1 + 1))
    end)
  end

  @sinosc "#{@fixtures}/synths/parsed/sinosc.ex"
  @saw "#{@fixtures}/synths/parsed/saw.ex"

  test "compiles a synth def into %Def" do
    {%Subject{synthdefs: [expected]} = sinosc, _} =
      @sinosc
      |> File.read!()
      |> Code.eval_string()

    %Subject{
      synthdefs: [
        %Subject.Synth{
          ugens: ugens,
          constants: constants,
          param_names: param_names,
          param_values: param_values,
          name: name
        }
      ]
    } =
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0,
        compile: false do
        sin_osc <- %SinOsc{freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0}
        out <- %Out{out_bus: out_bus, mono: sin_osc}
      end

    # IO.inspect({sinosc, synthdef})

    assert name == expected.name
    assert ugens == expected.ugens
    assert constants == expected.constants
    assert param_names == expected.param_names
    assert param_values == expected.param_values

    expected = Subject.compile(sinosc)

    compiled =
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc <- %SinOsc{freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0}
        out <- %Out{out_bus: out_bus, mono: sin_osc}
      end

    assert expected == compiled
  end

  # test "compiles a more complex synth def into %Def" do
  #   {saw, _} =
  #     @saw
  #     |> File.read!()
  #     |> Code.eval_string()

  #   synthdef =
  #     defsynth Saw,
  #       # midi A4
  #       note: 69,
  #       out_bus: 0,
  #       foo: 0,
  #       bar: 0,
  #       compile: false do

  #       freq = midicps(note)
  #       freq2 = freq * 2
  #       sawfreq = if foo > 0.5, do: freq, else: freq2

  #       saw <- %Saw{
  #         freq: sawfreq,
  #         phase: 0.0,
  #         mul: 1.0,
  #         add: 2.0
  #       }

  #       # pulse <- %Pulse{
  #       #   freq: if bar > 0, do: midicps(note), else: midicps(note * 2.0)
  #       #   mul: 3.0,
  #       #   add: 4.0
  #       # }
  #       out <- %Out{out_bus: out_bus, mono: sin_osc}
  #     end

  #   assert synthdef = saw
  # end

  # test "compiles synth with submodules into ast" do
  #   defsubmodule Bar(

  #   )

  #   ast = defsynth Foo(
  #     note \\ 64
  #   ) do
  #     bar <- Bar(note)
  #     out <- Ugen.SinOsc(bar)
  #   end
  # end
end
