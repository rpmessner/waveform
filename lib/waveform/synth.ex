defmodule Waveform.Synth do
  alias Harmony.Note
  alias Harmony.Chord

  alias Waveform.OSC
  alias Waveform.OSC.Group
  alias Waveform.OSC.Node

  alias Waveform.Synth.Manager

  import Waveform.Util

  def current_synth() do
    Manager.current_synth_name(self())
  end

  def use_synth(synth) do
    Manager.set_current_synth(self(), synth)
  end

  def play(n), do: play(n, [])

  def play(%Chord{} = c, options) do
    name =
      "#{c.tonic} #{c.quality}#{if c.root_degree > 0, do: " #{c.root}", else: ""} #{c.root_degree + 1}"

    group =
      if options[:group] do
        Group.chord_group(name, options[:group])
      else
        Group.chord_group(name)
      end

    c.notes
    |> Enum.map(fn note ->
      synth(note, options |> Keyword.put(:group, group))
    end)
  end

  def synth(note), do: synth(note, [])

  def synth(note, opts) when is_binary(note) do
    Note.get(note).midi
    |> synth(opts)
  end

  def synth(note, opts) when is_number(note) do
    {group, args} = group_arg(opts |> Enum.into(%{}))

    args
    |> calculate_sustain()
    |> Enum.reduce([:note, note], normalizer())
    |> synth(group)
  end

  def synth(opts, %Group{in_bus: out_bus} = g) when out_bus != nil do
    %{id: group_id} = g
    trigger_synth(group_id, [:out_bus, out_bus | opts])
  end

  def synth(opts, %Group{} = g) do
    %{id: group_id} = g
    trigger_synth(group_id, opts)
  end

  defp trigger_synth(group_id, opts) do
    %Node{id: node_id} = Node.next_synth_node()
    synth_name = Manager.current_synth_value(self())
    add_action = :head

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.new_synth(synth_name, node_id, add_action, group_id, opts)
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
