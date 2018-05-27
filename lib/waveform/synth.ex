defmodule Waveform.Synth do
  alias Waveform.Music, as: Music
  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Node.ID, as: ID

  import Waveform.Util

  @params_whitelist [
    :amp, :pan, :release, :attack, :sustain
  ]
  @s_new 's_new'
  @default_synth 'sonic-pi-prophet'

  def play(note), do: synth(note)
  def play(note, args), do: synth(note, args)

  def synth(note) when is_atom(note), do: (note |> Music.to_midi |> play)
  def synth(note) when is_number(note), do: play([:note, note])
  def synth(note, args) when is_atom(note), do: play(Music.to_midi(note), args)
  def synth(note, args) when is_list(args), do: play(note, Enum.into(args, %{}))
  def synth(note, args) when is_number(note) and is_map(args) do
    args
    |> calculate_sustain
    |> Enum.reduce([:note, note], normalizer)
    |> synth
  end
  def synth(args) when is_list(args) do
    node_id = ID.next_id
    group_id = 0
    synth_name = @default_synth
    add_action = 0
    group_id = 0

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.send_command([@s_new, synth_name, node_id, add_action, group_id | args])
  end

  defp normalizer, do: fn {key, value}, coll ->
    if Enum.member?(@params_whitelist, key) && is_number(value) do
      [key, value | coll]
    else
      coll
    end
  end
end
