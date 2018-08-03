defmodule Waveform.Midi do
  use GenServer
  @me __MODULE__

  defmodule State do
    defstruct(callbacks: [], pid: nil)
  end

  def on_midi(callback) do
    GenServer.call(@me, {:on_midi, callback})
  end

  def listen(name) do
    GenServer.call(@me, {:listen, name})
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state(), name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:listen, name}, _from, state) do
    pid =
      spawn(fn ->
        {:ok, input} = PortMidi.open(:input, name)
        PortMidi.listen(input, self())
        midi_receive(input, state)
      end)

    {:reply, {:ok, pid}, %{state | pid: pid}}
  end

  def handle_call({:on_midi, callback}, _from, state) do
    new_state = %{state | callbacks: state.callbacks ++ [callback]}
    {:reply, :ok, new_state}
  end

  defp midi_receive(input, state) do
    receive do
      {^input, [{event, time}]} ->
        Enum.map(state.callbacks, fn callback ->
          callback.(event)
        end)

      _ ->
        nil
    end

    midi_receive(input, state)
  end

  defp default_state do
    %State{}
  end
end
