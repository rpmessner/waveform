defmodule Waveform.Music.Util do
  @roman_intervals %{
    :I => "1P",
    :i => "1P",
    :IIb => "2m",
    :iib => "2m",
    :II => "2M",
    :ii => "2M",
    :IIIb => "3m",
    :iiib => "3m",
    :III => "3M",
    :iii => "3M",
    :IV => "4P",
    :iv => "4P",
    :Vb => "5b",
    :vb => "5b",
    :V => "5P",
    :v => "5P",
    :VIb => "6m",
    :vib => "6m",
    :VI => "6M",
    :vi => "6M",
    :VIIb => "7m",
    :viib => "7m",
    :VII => "7M",
    :vii => "7M"
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

  def octave_steps do
    @octave_steps
  end

  def interval_steps do
    @interval_steps
  end

  def roman_intervals do
    @roman_intervals
  end

  def roman_interval(roman) do
    @roman_intervals[roman]
  end
end
