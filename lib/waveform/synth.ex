defmodule Waveform.Synth do
  alias Waveform.Music.Note, as: Note
  alias Waveform.Music.Chord, as: Chord

  alias Waveform.OSC, as: OSC
  alias Waveform.OSC.Group, as: Group
  alias Waveform.OSC.Node, as: Node
  alias Waveform.Synth.Manager, as: Manager

  import Waveform.Util

  @params_whitelist [
    :amp,
    :pan,
    :release,
    :attack,
    :sustain
  ]
  @s_new 's_new'

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

  def synth(note) when is_atom(note), do: note |> Note.to_midi() |> play
  def synth(note) when is_number(note), do: play([:note, note])
  def synth(note, args) when is_atom(note), do: play(Note.to_midi(note), args)
  def synth(note, args) when is_list(args), do: play(note, Enum.into(args, %{}))

  def synth(note, args) when is_number(note) and is_map(args) do
    {group, args} = group_arg(args)

    IO.inspect({note, args})

    args
    |> calculate_sustain
    |> Enum.reduce([:note, note], normalizer)
    |> synth(group)
  end

  def synth(args, %Group{id: group_id}) when is_list(args) do
    %Node{id: node_id} = Node.next_node()
    synth_name = Manager.current_synth()
    add_action = 0

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    OSC.send_command([@s_new, synth_name, node_id, add_action, group_id | args])
  end

  def chord(tonic, quality, options \\ []) do
    options_map = Enum.into(options, %{})
    struct(Chord, Map.merge(%{tonic: tonic, quality: quality}, options_map))
  end

  defp group_arg(args) do
    case args[:group] do
      %Group{} = g -> {g, Map.delete(args, :group)}
      nil -> {Group.root_group(), args}
    end
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

    @me __MODULE__

    @synth_names %{
      prophet: 'sonic-pi-prophet',
      saw: 'sonic-pi-saw',
      dsaw: 'sonic-pi-dsaw',
      fm: 'sonic-pi-fm',
      pulse: 'sonic-pi-pulse',
      tb303: 'sonic-pi-tb303'
    }
    @default_synth @synth_names[:prophet]

    defmodule State do
      defstruct(current: nil)
    end

    def set_current_synth(next) do
      GenServer.call(@me, {:set_current, next})
    end

    def current_synth_atom() do
      current_name = GenServer.call(@me, {:current})

      {name, _} =
        Enum.find(@synth_names, fn {key, value} ->
          value == current_name
        end)

      name
    end

    def current_synth() do
      GenServer.call(@me, {:current})
    end

    def start_link(_state) do
      GenServer.start_link(@me, %State{current: @default_synth}, name: @me)
    end

    def init(state) do
      {:ok, state}
    end

    def terminate(_reason, _state), do: nil

    def handle_call({:set_current, new}, _from, state) do
      name = @synth_names[new]
      {:reply, if(name, do: new), %State{state | current: name || state.current}}
    end

    def handle_call({:current}, _from, state) do
      {:reply, state.current, state}
    end
  end
end
