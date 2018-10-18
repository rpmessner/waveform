defmodule Waveform.Synth.Def.CompileTest do
  use ExUnit.Case
  use ExUnit.Case

  alias Waveform.Synth.Def.Compile, as: Subject

  @fixtures __ENV__.file
            |> Path.dirname()
            |> Path.join("../../../fixtures/")
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

    chunk_size = 8

    expected_chunks =
      for <<expected::size(chunk_size) <- result>>, do: <<expected::size(chunk_size)>>

    actual_chunks = for <<actual::size(chunk_size) <- compiled>>, do: <<actual::size(chunk_size)>>

    Enum.zip(expected_chunks, actual_chunks)
    |> Enum.with_index()
    |> Enum.map(fn {{expected_byte, actual_byte}, idx} ->
      assert {^idx, ^expected_byte} = {idx, actual_byte}
    end)
  end
end
