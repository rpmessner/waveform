defmodule Waveform.Loop.Manager do
  use GenServer

  @me __MODULE__

  defmodule Loop do
    defstruct(name: nil, pid: nil)
  end

  defmodule State do
    defstruct(loops: [])
  end

  def store(name, pid) do
    GenServer.cast(@me, {:store, name, pid})
  end

  def kill(name) do
    GenServer.cast(@me, {:kill, name})
  end

  def kill_all do
    GenServer.cast(@me, {:kill_all})
  end

  def start_link(_options) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:store, name, pid}, state) do
    {:noreply, %{state | loops: [%Loop{name: name, pid: pid} | state.loops]}}
  end

  def handle_cast({:kill, name}, state) do
    loop = Enum.find state.loops, &(&1.name == name)

    Process.exit(loop.pid, :kill)

    loops = Enum.filter state.loops, &(&1.name != name)

    {:noreply, %{state | loops: loops}}
  end

  def handle_cast({:kill_all}, state) do
    Enum.each(state.loops, fn loop ->
      Process.kill(loop.pid)
    end)
    {:noreply, %{state | loops: []}}
  end
end
