defmodule Waveform.Synth.DefTest do
  use ExUnit.Case
  alias Waveform.Synth.Def, as: Subject

  require Subject
  import Subject

  @fixtures __ENV__.file
            |> Path.dirname()
            |> Path.join("../../fixtures/")
            |> to_charlist

  @synthdef "#{@fixtures}/beep.scsyndef"
  @synthdata "#{@fixtures}/beep.ex"

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

  test "compiles a synth def into %Def" do
    synthdef =
      defsynth Foo,
        # midi A4
        note: 69,
        out_bus: 0 do
        sin_osc <- %SinOsc{freq: midicps(note), phase: 0.0, mul: 1.0, add: 2.0}
        out <- %Out{out_bus: out_bus, mono: sin_osc}
      end

    assert %Subject{
      synthdefs: [
        %Subject.Synth{
          constants: [
            0.0, #phase
            1.0, #mul
            2.0, #add
          ],
          name: "Foo",
          param_names: ["note","out_bus"],
          params: [
            69.0, #A 440
            0.0 #out_bus
          ],
          ugens: [
            %Subject.Ugen{
              name: "Control",
              inputs: [],
              outputs: [
                1,
                1
              ],
              rate: 1, #lfo
              special: 0,
            },
            %Subject.Ugen{
              name: "UnaryOpUgen",
              rate: 1,
              special: 17,
              inputs: [
                 %Subject.Ugen.Input{src: 0, constant_index: 0}, #midi
              ],
              outputs: [
                1
              ]
            },
            %Subject.Ugen{
               name: "SinOsc",
               inputs: [
                 %Subject.Ugen.Input{src: 1, constant_index: 0}, #freq
                 %Subject.Ugen.Input{src: -1, constant_index: 0}, #phase
                 %Subject.Ugen.Input{src: -1, constant_index: 1}, #mul
                 %Subject.Ugen.Input{src: -1, constant_index: 2} #add
               ],
               rate: 2,
               special: 0,
               outputs: [2],
             },
             %Subject.Ugen{
               inputs: [
                 %Subject.Ugen.Input{constant_index: 1, src: 0}, #out_bus
                 %Subject.Ugen.Input{constant_index: 0, src: 2}, #sin_osc out0
               ],
               name: "Out",
               rate: 2, #hfo
               special: 0
             }
           ]
        }
      ]
    } = synthdef
  end

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
