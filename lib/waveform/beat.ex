defmodule Waveform.Beat do
  use GenServer

  alias Waveform.Util, as: Util
  alias Waveform.OSC.Group, as: Group

  alias __MODULE__
  @me __MODULE__

  defmodule State do
    defstruct(
      bpm: 90,
      started: false,
      start_time: nil,
      tref: nil,
      current_beat: 1,
      callbacks: []
    )
  end

  defmodule Tick do
    defstruct(
      group: nil,
      beats: 3,
      over: 4,
      name: nil,
      # swing: 0.5,
      func: nil
    )

    def tick() do
      Beat.tick()
    end

    def handle_callback(%Tick{group: group, over: over, beats: beats, func: func}, idx) do
      counter = :os.perf_counter(1000)

      # IO.inspect {self(), "#{over} over #{beats}", idx, counter}

      if group && group.id do
        Group.activate_group(group.id)
      end

      if Beat.state().started do
        func.(%{beat: idx, counter: counter})
      end
    end
  end

  def clear do
    GenServer.call(@me, {:clear})
  end

  def tick do
    GenServer.call(@me, {:tick})
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def reset do
    GenServer.cast(@me, {:reset})
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

  def on_beat(name, beats, func) when is_atom(name), do: on_beat(name, beats, beats, func)

  def on_beat(name, over, beats, func) when is_atom(name) do
    GenServer.cast(@me, {:on_beat, name, beats, over, func, nil})
  end

  def on_beat(beats, func) when is_integer(beats), do: on_beat(beats, beats, func)

  def on_beat(over, beats, func) when is_integer(beats) do
    GenServer.cast(@me, {:on_beat, nil, beats, over, func, nil})
  end

  def on_beat(name, beats, func, %Group{} = group) when is_atom(name),
    do: on_beat(name, beats, beats, func, group)

  def on_beat(name, over, beats, func, %Group{} = group) when is_integer(beats) do
    GenServer.cast(@me, {:on_beat, name, beats, over, func, group})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:on_beat, name, beats, over, func, %Group{} = group}, state) do
    {:noreply,
     %{
       state
       | callbacks: [
           %Tick{group: group, name: name, over: over, beats: beats, func: func} | state.callbacks
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

    unless state.tref do
      {:ok, tref} = :timer.apply_interval(ms, Tick, :tick, [])

      counter = :os.perf_counter(10)
    end

    {:noreply, %{state | started: true, start_time: counter, tref: tref}}
  end

  def handle_cast({:set_bpm, bpm}, state) do
    {:noreply, %{state | bpm: bpm}}
  end

  def handle_call({:tick}, _from, state) do
    Enum.each(state.callbacks, fn %Tick{
                                    beats: beats,
                                    over: over,
                                    func: callback
                                  } = s ->
      if beats == 1 || rem(state.current_beat, beats) == 1 do
        beat_value = beat_value(state)

        Enum.each(0..(over - 1), fn idx ->
          spawn(fn ->
            (beat_value * (beats / over) * idx)
            |> Float.round()
            |> Kernel.trunc()
            |> :timer.apply_after(Tick, :handle_callback, [s, idx])
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
