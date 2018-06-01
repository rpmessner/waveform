defmodule Waveform.Loop.Manager do
  use GenServer

  @me __MODULE__

  defmodule Loop do
    defstruct(group: nil, name: nil, pid: nil, func: nil)
  end

  defmodule State do
    defstruct(loops: [])
  end

  def state() do
    GenServer.call(@me, {:state})
  end

  def store(name, func, pid) do
    GenServer.cast(@me, {:store, name, func, pid})
  end

  def resume(name) do
    GenServer.cast(@me, {:resume, name})
  end

  def pause(name) do
    GenServer.cast(@me, {:pause, name})
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

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:store, name, func, pid}, state) do
    {:noreply, %{state | loops: [%Loop{func: func, name: name, pid: pid} | state.loops]}}
  end

  def handle_cast({:kill, name}, state) do
    {loop, loops} = get_loop(state.loops, name)

    Process.exit(loop.pid, :kill)

    {:noreply, %{state | loops: loops}}
  end

  def handle_cast({:pause, name}, state) do
    {loop, _} = get_loop(state.loops, name)

    Process.exit(loop.pid, :kill)

    {:noreply, state}
  end

  def handle_cast({:resume, name}, state) do
    {loop, loops} = get_loop(state.loops, name)

    pid = spawn(loop.func)

    loop = %{loop | pid: pid}

    {:noreply, %{state | loops: [loop | loops]}}
  end

  defp get_loop(loops, name) do
    {Enum.find(loops, &(&1.name == name)), Enum.filter(loops, &(&1.name != name))}
  end

  def handle_cast({:kill_all}, state) do
    Enum.each(state.loops, fn loop ->
      Process.exit(loop.pid, :kill)
    end)

    {:noreply, %{state | loops: []}}
  end
end
