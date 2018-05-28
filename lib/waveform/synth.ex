defmodule Waveform.Synth do
  alias Waveform.Music.Note, as: Note
  alias Waveform.Music.Chord, as: Chord

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node, as: Node

  import Waveform.Util

  @params_whitelist [
    :amp,
    :pan,
    :release,
    :attack,
    :sustain
  ]
  @s_new 's_new'

  def play(%Chord{} = c), do: play(c, [])

  def play(%Chord{} = c, options) do
    c
    |> Chord.notes()
    |> Enum.map(&synth(&1, options))
  end

  def play(note), do: synth(note)
  def play(note, args), do: synth(note, args)

  def synth(note) when is_atom(note), do: note |> Note.to_midi() |> play
  def synth(note) when is_number(note), do: play([:note, note])
  def synth(note, args) when is_atom(note), do: play(Note.to_midi(note), args)
  def synth(note, args) when is_list(args), do: play(note, Enum.into(args, %{}))

  def synth(note, args) when is_number(note) and is_map(args) do
    args
    |> calculate_sustain
    |> Enum.reduce([:note, note], normalizer)
    |> synth
  end

  def synth(args) when is_list(args) do
    node_id = Node.next_id()
    group_id = Group.synth_group()
    synth_name = Manager.current_synth()
    add_action = 0

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.send_command([@s_new, synth_name, node_id, add_action, group_id | args])
  end

  def chord(tonic, quality) do
    %Chord{tonic: tonic, quality: quality}
  end

  def chord(tonic, quality, inversion: inversion) do
    %Chord{tonic: tonic, quality: quality, inversion: inversion}
  end

  defp normalizer,
    do: fn {key, value}, coll ->
      if Enum.member?(@params_whitelist, key) && is_number(value) do
        [key, value | coll]
      else
        coll
      end
    end

  defmodule Manager do
    use GenServer

    @default_synth 'sonic-pi-prophet'
    @me __MODULE__

    defmodule State do
      defstruct(current: @default_synth)
    end

    def start_link(_state) do
      GenServer.start_link(@me, %State{}, name: @me)
    end

    def init(state) do
      {:ok, state}
    end

    def terminate(_reason, _state), do: nil

    def handle_call({:set_current, new}, _from, state) do
      {:reply, %State{state | current: new}}
    end

    def handle_call({:current}, _from, state) do
      {:reply, state.current}
    end
  end
end
