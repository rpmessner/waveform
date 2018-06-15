defmodule Waveform.Synth do
  alias Waveform.Beat, as: Beat

  alias Waveform.Music.Note, as: Note
  alias Waveform.Music.Chord, as: Chord

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node, as: Node

  alias Waveform.Synth.Manager, as: Manager

  import Waveform.Util

  def current_synth() do
    Manager.current_synth_name(self())
  end

  def use_synth(synth) do
    Manager.set_current_synth(self(), synth)
  end

  def stop, do: Beat.stop()
  def start, do: Beat.start()
  def pause, do: Beat.pause()

  def play(%Chord{} = c), do: play(c, [])
  def play(note), do: synth(note)

  def play(%Chord{} = c, options) do
    name = "#{c.tonic} #{c.quality} #{c.inversion}"

    group =
      if options[:group] do
        Group.chord_group(name, options[:group])
      else
        Group.chord_group(name)
      end

    c
    |> Chord.notes()
    |> Enum.map(&synth(&1, options |> Enum.into(%{}) |> Map.merge(%{group: group})))
  end

  def play(note, args), do: synth(note, args)

  def synth(note) when is_atom(note), do: note |> Note.to_midi() |> synth
  def synth(note) when is_number(note), do: synth(note, [])
  def synth(note, args) when is_atom(note), do: play(Note.to_midi(note), args)
  def synth(note, args) when is_list(args), do: play(note, Enum.into(args, %{}))

  def synth(note, args) when is_number(note) and is_map(args) do
    {group, args} = group_arg(args)

    args
    |> calculate_sustain
    |> Enum.reduce([:note, note], normalizer())
    |> synth(group)
  end

  def synth(args, nil) when is_list(args) do
    synth(args, Group.synth_group(self()))
  end

  def synth(args, %Group{
        in_bus: out_bus,
        id: group_id
      })
      when is_list(args) and out_bus != nil do
    trigger_synth([:out_bus, out_bus | args], group_id)
  end

  def synth(args, %Group{id: group_id}) when is_list(args) do
    trigger_synth(args, group_id)
  end

  defp trigger_synth(args, group_id) do
    %Node{id: node_id} = Node.next_synth_node()
    synth_name = Manager.current_synth_value(self())
    add_action = :head

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.new_synth(synth_name, node_id, add_action, group_id, args)
  end

  def chord(tonic, quality, options \\ []) do
    options_map = Enum.into(options, %{})
    struct(Chord, Map.merge(%{tonic: tonic, quality: quality}, options_map))
  end

  defp group_arg(args) do
    case args[:group] do
      %Group{} = g ->
        {g, Map.delete(args, :group)}

      nil ->
        {Group.synth_group(self()), args}
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
