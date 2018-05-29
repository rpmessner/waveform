defmodule Waveform.Synth do
  alias Waveform.Music.Note, as: Note
  alias Waveform.Music.Chord, as: Chord

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node, as: Node

  alias Waveform.Synth.FX, as: FX
  alias Waveform.Synth.Manager, as: Manager

  import Waveform.Util

  @synth_params_whitelist ~w(
    amp
    amp_slide
    pan
    pan_slide
    release
    attack
    attack_level
    sustain
    sustain_level
    decay
    decay_level
    slide
    env_curve
  )a

  def current_synth() do
    Manager.current_synth_atom()
  end

  def use_synth(synth) do
    Manager.set_current_synth(synth)
  end

  def play(%Chord{} = c), do: play(c, [])

  def play(%Chord{} = c, options) do
    group = Group.chord_group()

    c
    |> Chord.notes()
    |> Enum.map(&synth(&1, options |> Enum.into(%{}) |> Map.merge(%{group: group})))
  end

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
    |> Enum.reduce([:note, note], normalizer(@synth_params_whitelist))
    |> synth(group)
  end

  def synth(args, %Group{id: group_id}) when is_list(args) do
    %Node{id: node_id} = Node.next_node()
    synth_name = Manager.current_synth()
    add_action = :head

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.new_synth(synth_name, node_id, add_action, group_id, args)
  end

  def chord(tonic, quality, options \\ []) do
    options_map = Enum.into(options, %{})
    struct(Chord, Map.merge(%{tonic: tonic, quality: quality}, options_map))
  end

  def use_fx(name), do: use_fx(name, [])

  def use_fx(name, args) do
    args_list = args |> Enum.reduce([], fn {key, value}, coll -> [key, value | coll] end)
    FX.new_fx(name, args_list)
  end

  def kill_fx do
    FX.kill_all()
  end

  defp group_arg(args) do
    case args[:group] do
      %Group{} = g -> {g, Map.delete(args, :group)}
      nil -> {Group.synth_group(), args}
    end
  end

  defp normalizer(whitelist),
    do: fn {key, value}, coll ->
      if Enum.member?(whitelist, key) && is_number(value) do
        [key, value | coll]
      else
        coll
      end
    end
end
