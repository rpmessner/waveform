defmodule Waveform.Beat do
  use GenServer

  alias Waveform.Util, as: Util

  alias __MODULE__
  @me __MODULE__

  defmodule State do
    defstruct(
      bpm: 90,
      start_time: nil,
      tref: nil,
      current_beat: 1,
      callbacks: []
    )
  end

  defmodule Callback do
    defstruct(
      beats: 3,
      superimposition: 4,
      # swing: 0.5,
      func: nil
    )
  end

  def clear do
    GenServer.call(@me, {:clear})
  end

  def tick do
    GenServer.cast(@me, {:tick})
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

  def on_beat(beats, func) do
    GenServer.cast(@me, {:on_beat, beats, beats, func})
  end

  def on_beat(beats, superimposition, func) do
    GenServer.cast(@me, {:on_beat, beats, superimposition, func})
  end

  def on_beat(func) do
    GenServer.cast(@me, {:on_beat, func})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:on_beat, beats, si, func}, state) do
    {:noreply,
     %{
       state
       | callbacks: [
           %Callback{superimposition: si, beats: beats, func: func} | state.callbacks
         ]
     }}
  end

  def handle_cast({:on_beat, func}, state) do
    {:noreply, %{state | callbacks: [%Callback{func: func} | state.callbacks]}}
  end

  defmodule Tick do
    def tick() do
      Beat.tick()
    end
  end

  def handle_cast({:pause}, state) do
    :timer.cancel(state.tref)

    {:noreply, %{state | tref: nil}}
  end

  def handle_cast({:stop}, state) do
    :timer.cancel(state.tref)

    {:noreply, %{state | tref: nil, current_beat: 0}}
  end

  def handle_cast({:start}, %State{tref: tref} = state) do
    ms = beat_value(state)

    unless state.tref do
      {:ok, tref} = :timer.apply_interval(ms, Tick, :tick, [])

      counter = :os.perf_counter(10)
    end

    {:noreply, %{state | start_time: counter, tref: tref}}
  end

  def handle_cast({:set_bpm, bpm}, state) do
    {:noreply, %{state | bpm: bpm}}
  end

  def handle_cast({:tick}, state) do
    counter = :os.perf_counter(10)
    # IO.inspect({"tick", state.current_beat, counter})

    Enum.each(state.callbacks, fn %Callback{
                                    beats: beats,
                                    superimposition: si,
                                    func: callback
                                  } = s ->
      # IO.inspect {state.current_beat, beats, rem(state.current_beat, beats)}

      if beats == 1 || rem(state.current_beat, beats) == 1 do
        if si == beats do
          # IO.inspect({"spawn single", state.current_beat, counter})
          spawn(fn ->
            callback.({counter, state.current_beat})
          end)
        else
          # IO.inspect({"spawn impos", state.current_beat, counter})
          spawn(fn ->
            beat_value = beat_value(state)

            Enum.each(1..si, fn idx ->
              callback.({idx, counter, state.current_beat})

              si_beat_value = beat_value * (beats / si)

              # IO.inspect {si_beat_value, beat_value}

              si_beat_value
              |> Kernel.trunc()
              |> Process.sleep()
            end)
          end)
        end
      end
    end)

    {:noreply, %{state | current_beat: state.current_beat + 1}}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  defp beat_value(state) do
    (60 / state.bpm) |> :timer.seconds() |> Float.round() |> Kernel.trunc()
  end

  def handle_call({:clear}, _from, state) do
    {:reply, nil, %{state | callbacks: []}}
  end
end
