defmodule Waveform.Music.Chord do
  alias Waveform.Music, as: Music
  alias __MODULE__

  defstruct(
    tonic: :c4,
    quality: :major7,
    inversion: 1
  )

  @chord_qualities %{
    major7: [:"1P", :"3M", :"5P", :"7M"]
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
    :"0" => 12
  }

  def chord(tonic, quality) do
    %Chord{tonic: tonic, quality: quality}
  end

  def chord(tonic, quality, inversion) do
    %Chord{tonic: tonic, quality: quality, inversion: inversion}
  end

  def notes(%Chord{}=c) do
    @chord_qualities[c.quality]
    |> Enum.map(fn interval ->
      Music.to_midi(c.tonic) + @interval_steps[interval]
    end)
  end
end
