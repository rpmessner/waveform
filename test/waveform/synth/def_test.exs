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

  @synthdef "#{@fixtures}/synths/compiled/beep.scsyndef"
  @synthdata "#{@fixtures}/synths/parsed/beep.ex"

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

    actual_chunks =
      for <<actual::size(chunk_size) <- compiled>>, do: <<actual::size(chunk_size)>>

    Enum.map(Enum.zip(expected_chunks, actual_chunks), fn {expected_byte, actual_byte} ->
      idx = Agent.get(counter, fn state -> state end)

      assert {^idx, ^expected_byte} = {idx, actual_byte}

      Agent.update(counter, &(&1 + 1))
    end)
  end

  @sinosc "#{@fixtures}/synths/parsed/sinosc.ex"
  @saw "#{@fixtures}/synths/parsed/saw.ex"

  test "compiles a synth def into %Def" do
    {expected, _} =
      @sinosc
      |> File.read!()
      |> Code.eval_string()

    {synthdef, compiled} =
      defsynth SinOscDef,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc <- %SinOsc{freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0}
        out <- %Out{out_bus: out_bus, mono: sin_osc}
      end

    assert_synthdef(
      expected,
      synthdef
    )

    expected = Subject.compile(expected)

    assert expected == compiled
  end

  test "compiles a more complex synth def into %Def" do
    { expected, _ } =
      @saw
      |> File.read!()
      |> Code.eval_string()


    {synthdef, compiled} =
      defsynth SawDef,
        # midi A4
        note: 69,
        out_bus: 0,
        foo: 0,
        bar: 0 do

        freq = midicps(note)
        freq2 = freq * 2.0

        sawfreq = if foo > 0.5, do: freq, else: freq2

        saw <- %Saw{
          freq: freq,
          phase: 0.0,
          mul: 1.0,
          add: 2.0
        }

        out <- %Out{out_bus: out_bus, mono: saw}
      end

    assert_synthdef(
      expected,
      synthdef
    )

    expected = Subject.compile(expected)

    assert expected == compiled
  end

  # test "compiles synth with submodules into %Def" do
  #   {expected, _} =
  #     @sinosc
  #     |> File.read!()
  #     |> Code.eval_string()

  #   defsubmodule Bar, note: 69 do
  #     freq = midicps(note)
  #     out <- %SinOsc{freq: freq, phase: 0.0, mul: 1.0, add: 2.0}
  #   end

  #   assert_synthdef(expected,
  #     defsynth Foo, note: 69, out_bus: 0, compile: false do
  #       bar <- %Bar{note: note}
  #       out <- %Out{out_bus: out_bus, mono: bar}
  #     end
  #   )
  # end
end
