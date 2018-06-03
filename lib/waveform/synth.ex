defmodule Waveform.Synth do
  alias Waveform.Beat, as: Beat

  alias Waveform.Music.Note, as: Note
  alias Waveform.Music.Chord, as: Chord

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node, as: Node

  alias Waveform.Synth.FX, as: FX
  alias Waveform.Synth.Manager, as: Manager

  import Waveform.Util

  def current_synth() do
    Manager.current_synth_name()
  end

  def use_synth(synth) do
    Manager.set_current_synth(synth)
  end

  def play(%Chord{} = c), do: play(c, [])

  def play(%Chord{} = c, options) do
    group = Group.chord_group("#{c.tonic} #{c.quality} #{c.inversion}")

    c
    |> Chord.notes()
    |> Enum.map(&synth(&1, options |> Enum.into(%{}) |> Map.merge(%{group: group})))
  end

  def stop, do: Beat.stop()
  def start, do: Beat.start()
  def pause, do: Beat.pause()

  def play(note), do: synth(note)
  def play(note, args), do: synth(note, args)

  def synth(note) when is_atom(note), do: note |> Note.to_midi() |> synth
  def synth(note) when is_number(note), do: synth(note, [])
  def synth(note, args) when is_atom(note), do: play(Note.to_midi(note), args)
  def synth(note, args) when is_list(args), do: play(note, Enum.into(args, %{}))

  def synth(note, args) when is_number(note) and is_map(args) do
    {group, args} = group_arg(args)

    args
    |> calculate_sustain
    |> Enum.reduce([:note, note], normalizer)
    |> synth(group)
  end

  def synth(args, nil) when is_list(args) do
    synth(args, Group.synth_group())
  end

  def synth(args, %Group{id: group_id}) when is_list(args) do
    %Node{id: node_id} = Node.next_node()
    synth_name = Manager.current_synth_value()
    add_action = :tail

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.new_synth(synth_name, node_id, add_action, group_id, args)
  end

  def chord(tonic, quality, options \\ []) do
    options_map = Enum.into(options, %{})
    struct(Chord, Map.merge(%{tonic: tonic, quality: quality}, options_map))
  end

  defp group_arg(args) do
    case args[:group] do
      %Group{} = g -> {g, Map.delete(args, :group)}
      nil ->
        IO.puts("using synth group")
        {Group.synth_group(), args}
    end
  end

  defp normalizer,
    do: fn {key, value}, coll ->
      if is_number(value) do
        [key, value | coll]
      else
        coll
      end
    end
end
