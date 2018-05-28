defmodule Waveform.Util do
  def calculate_sustain(args) do
    if Map.has_key?(args, :duration) and !Map.has_key?(args, :sustain) do
      attack = args[:attack] || 0
      decay = args[:decay] || 0
      release = args[:release] || 0
      duration = args[:duration]
      sustain = duration - (attack + decay + release)

      args
      |> Map.delete(:duration)
      |> Map.merge(%{sustain: Enum.max([0, sustain])})
    else
      args
    end
  end
end
