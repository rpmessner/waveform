defmodule Waveform.Synth.DefTest do
  use ExUnit.Case
  alias Waveform.Synth.Def, as: Subject

  @fixtures __ENV__.file
            |> Path.dirname()
            |> Path.join("../../fixtures/")
            |> to_charlist

  @synthdef "#{@fixtures}/beep.scsyndef"
  @synthdata "#{@fixtures}/beep.ex"

  test "compiles a synth def into binary" do
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

    Enum.map(Enum.zip(expected_chunks, actual_chunks), fn {ex, ac} ->
      idx = Agent.get(counter, fn state -> state end)

      assert {^idx, ^ex} = {idx, ac}

      Agent.update(counter, &(&1 + 1))
    end)
  end
end
