defmodule Waveform.Beat do
  use GenServer

  alias Waveform.OSC.Group
  alias Waveform.Synth.Manager

  alias __MODULE__
  @me __MODULE__

  defmodule State do
    defstruct(
      bpm: 90,
      started: false,
      start_time: nil,
      tref: nil,
      current_beat: 0,
      callbacks: []
    )
  end

  defmodule Tick do
    defstruct(
      group: nil,
      synth: nil,
      beats: 3,
      over: 4,
      name: nil,
      # swing: 0.5,
      func: nil
    )

    def tick() do
      Beat.tick()
    end

    def handle_callback(
          %Tick{synth: synth, group: group, over: _over, beats: _beats, func: func},
          idx,
          beat
        ) do
      counter = :os.perf_counter(1000)

      %State{started: started} = _state = Beat.state()

      if started do
        if synth != nil do
          Manager.set_current_synth(self(), synth)
        end

        Group.activate_synth_group(self(), group)
        func.(%{beat: beat, measure_beat: idx, counter: counter})
        Group.restore_synth_group(self())

        if synth != nil do
          Manager.use_last_synth(self())
        end
      end
    end
  end

  def tick do
    GenServer.call(@me, {:tick})
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def reset do
    GenServer.call(@me, {:clear})
  end

  def start do
    GenServer.cast(@me, {:start})
  end

  def stop do
    GenServer.cast(@me, {:stop})
  end

  def pause do
    GenServer.cast(@me, {:pause})
  end

  def set_bpm(bpm) when is_number(bpm) do
    GenServer.cast(@me, {:set_bpm, bpm})
  end

  def start_link(_options) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def on_beat(beats, func) when is_integer(beats),
    do: on_beat(beats: beats, over: beats, func: func)

  def on_beat(name, beats, func) when is_atom(name),
    do: on_beat(name: name, beats: beats, over: beats, func: func)

  def on_beat(over, beats, func) when is_integer(over) and is_integer(beats),
    do: on_beat(beats: beats, over: over, func: func)

  def on_beat(name, over, beats, func) when is_atom(name),
    do: on_beat(name: name, beats: beats, over: over, func: func)

  def on_beat(name, beats, func, group)
      when is_integer(beats) and is_function(func) and is_atom(name),
      do: on_beat(name: name, beats: beats, over: beats, func: func, group: group)

  def on_beat(options \\ []) do
    GenServer.cast(@me, {
      :on_beat,
      options[:name],
      options[:over],
      options[:beats],
      options[:func],
      options[:group],
      options[:synth]
    })
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:on_beat, name, beats, over, func, group, synth}, state) do
    callbacks = Enum.filter(state.callbacks, fn %Tick{name: name} -> name != name end)

    {:noreply,
     %{
       state
       | callbacks: [
           %Tick{group: group, name: name, over: over, beats: beats, func: func, synth: synth}
           | callbacks
         ]
     }}
  end

  def handle_cast({:pause}, state) do
    :timer.cancel(state.tref)

    {:noreply, %{state | tref: nil, started: false}}
  end

  def handle_cast({:stop}, state) do
    :timer.cancel(state.tref)

    {:noreply, %{state | tref: nil, started: false, current_beat: 0}}
  end

  def handle_cast({:start}, %State{tref: tref} = state) do
    ms = beat_value(state)

    {:ok, tref} =
      unless state.tref do
        :timer.apply_interval(ms, Tick, :tick, [])
      else
        {:ok, tref}
      end

    counter = :os.perf_counter(10)

    {:noreply, %{state | started: true, start_time: counter, tref: tref}}
  end

  def handle_cast({:set_bpm, bpm}, state) do
    {:noreply, %{state | bpm: bpm}}
  end

  def handle_call({:tick}, _from, state) do
    Enum.each(state.callbacks, fn %Tick{
                                    beats: beats,
                                    over: over
                                  } = s ->
      if beats == 1 || rem(state.current_beat, beats) == 1 do
        beat_value = beat_value(state)

        Enum.each(0..(over - 1), fn idx ->
          spawn(fn ->
            (beat_value * (beats / over) * idx)
            |> Float.round()
            |> Kernel.trunc()
            |> :timer.apply_after(Tick, :handle_callback, [s, idx, state.current_beat])
          end)
        end)
      end
    end)

    {:reply, nil, %{state | current_beat: state.current_beat + 1}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:clear}, _from, state) do
    {:reply, nil, %{state | callbacks: []}}
  end

  defp beat_value(state) do
    (60 / state.bpm) |> :timer.seconds() |> Float.round() |> Kernel.trunc()
  end
end
