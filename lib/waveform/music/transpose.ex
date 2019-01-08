defmodule Waveform.Music.Transpose do
  alias Waveform.Music.Util

  @notes ~w(c db d eb e f gb g ab a bb b)

  def transpose_roman(note, roman) do
    transpose_note(
      note,
      Util.roman_interval(roman)
    )
  end

  def transpose_note(note, interval) when is_binary(interval) do
    transpose_note(note, String.to_atom(interval))
  end

  def transpose_note(note, interval) do
    index = Enum.find_index(@notes, fn n -> n == to_string(note) end)
    steps_hash = Util.interval_steps()
    steps = steps_hash[interval]
    index = rem(steps + index, 12)
    :"#{Enum.at(@notes, index)}"
  end
end
