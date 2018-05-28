defmodule Waveform.Music.Chord do
  alias Waveform.Music.Note, as: Note
  alias __MODULE__

  defstruct(
    tonic: :c4,
    quality: :major7,
    inversion: 0
  )

  @chord_qualities %{
    major: [:"1P", :"3M", :"5P"],
    minor: [:"1P", :"3m", :"5P"],
    major7: [:"1P", :"3M", :"5P", :"7M"],
    dominant7: [:"1P", :"3M", :"5P", :"7m"],
    minor7: [:"1P", :"3m", :"5P", :"7m"],
    dominant7b5: [:"1P", :"3M", :"5b", :"7m"],
    half_diminished7: [:"1P", :"3m", :"5b", :"7m"],
    diminished7: [:"1P", :"3m", :"5b", :"7bb"]
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
