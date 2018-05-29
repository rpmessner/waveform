defmodule Waveform.Music.Chord do
  alias Waveform.Music.Note, as: Note
  alias __MODULE__

  defstruct(
    tonic: :c4,
    quality: :major7,
    inversion: 0
  )

  maj = [:"1P", :"3M", :"5P"]
  min = [:"1P", :"3m", :"5P"]
  dim = [:"1P", :"3m", :"5b"]
  maj6 = [:"1P", :"3M", :"5P", :"6M"]
  maj7 = [:"1P", :"3M", :"5P", :"7M"]
  dom7 = [:"1P", :"3M", :"5P", :"7m"]
  min6 = [:"1P", :"3m", :"5P", :"6M"]
  min7 = [:"1P", :"3m", :"5P", :"7m"]
  halfdim = [:"1P", :"3m", :"5b", :"7m"]
  dim7 = [:"1P", :"3m", :"5b", :"7bb"]

  @chord_qualities %{
    dim: dim,
    diminished: dim,
    maj: maj,
    major: maj,
    min: min,
    minor: min,
    maj6: maj6,
    major6: maj6,
    maj7: maj7,
    major7: maj7,
    sus2: [:"1P", :"2M", :"5P"],
    sus4: [:"1P", :"4P", :"5P"],
    dom7: dom7,
    dominant7: dom7,
    minor6: min6,
    min6: min6,
    minor7: min7,
    min7: min7,
    dom7b5: [:"1P", :"3M", :"5b", :"7m"],
    dom7alt: [:"1P", :"3M", :"5A", :"7m"],
    halfdim: halfdim,
    halfdim7: halfdim,
    halfdiminished: halfdim,
    halfdiminished7: halfdim,
    half_diminished: halfdim,
    half_diminished7: halfdim,
    diminished7: dim7,
    dim7: dim7
  }

  @interval_steps %{
    :"1P" => 0,
    :"2m" => 1,
    :"2M" => 2,
    :"3m" => 3,
    :"3M" => 4,
    :"4P" => 5,
    :"4A" => 6,
    :"5b" => 6,
    :"5P" => 7,
    :"5A" => 8,
    :"6m" => 8,
    :"6M" => 9,
    :"7bb" => 9,
    :"7m" => 10,
    :"7M" => 11,
    :O => 12
  }

  @octave_steps @interval_steps[:O]

  def notes(%Chord{} = c) do
    @chord_qualities[c.quality]
    |> Enum.with_index()
    |> Enum.map(fn {interval, idx} ->
      note = Note.to_midi(c.tonic) + @interval_steps[interval]

      if idx < c.inversion do
        note + @octave_steps
      else
        note
      end
    end)
  end
end
