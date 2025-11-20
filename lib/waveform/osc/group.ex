defmodule Waveform.OSC.Group do
  @moduledoc """
  Manages group allocation and hierarchy for SuperCollider.

  Groups organize synths into a tree structure. This module provides basic
  group management with per-process group tracking for scoped group activation.

  Process monitors ensure that dead processes don't leak memory in the
  per-process group tracking.
  """
  use GenServer

  @me __MODULE__
  alias __MODULE__

  alias Waveform.OSC
  alias Waveform.OSC.Node.ID

  defstruct(
    id: nil,
    name: nil,
    type: nil,
    children: [],
    nodes: [],
    out_bus: nil,
    in_bus: nil,
    parent: nil
  )

  defmodule State do
    @moduledoc false
    defstruct(
      root_group: %Group{id: 1, name: :root},
      root_synth_group: nil,
      # Map of pid => group (single group per process)
      process_groups: %{},
      # Map of monitor_ref => pid for cleanup
      monitors: %{}
    )
  end

  def reset do
    GenServer.call(@me, {:reset})
  end

  def state do
    GenServer.call(@me, {:state})
  end

  @doc """
  Set the current group for a process.

  This replaces any previously set group for the process.
  The process will be monitored and automatically cleaned up when it dies.

  ## Examples

      group = Group.new_group("my-group")
      Group.set_process_group(self(), group)
  """
  def set_process_group(pid, %Group{} = group) when is_pid(pid) do
    GenServer.call(@me, {:set_process_group, pid, group})
  end

  @doc """
  Get the current group for a process.

  Returns the process's current group, or the root synth group if none is set.

  ## Examples

      Group.get_process_group(self())
  """
  def get_process_group(pid) when is_pid(pid) do
    %State{process_groups: pg, root_synth_group: rsg} = state()
    pg[pid] || rsg
  end

  @doc """
  Get the synth group for a process (backwards compatibility).

  This is an alias for `get_process_group/1`.
  """
  def synth_group(pid) when is_pid(pid) do
    get_process_group(pid)
  end

  def setup do
    GenServer.call(@me, {:root_synth_group})
  end

  @doc """
  Create a new group with the given name.

  ## Examples

      Group.new_group("my-group")
      Group.new_group("my-group", parent_group)
  """
  def new_group(name, parent \\ nil) do
    parent = parent || synth_group(self()) || state().root_synth_group
    GenServer.call(@me, {:new_group, name, :custom, :head, parent})
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state(), name: @me)
  end

  defp default_state do
    %State{}
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:root_synth_group}, _from, state) do
    group = %Group{type: :synth, name: :root_synth_group, id: ID.next()}

    create_group(group.id, :head, state.root_group.id)

    {:reply, :ok, %{state | root_synth_group: group}}
  end

  def handle_call(
        {:set_process_group, pid, %Group{} = group},
        _from,
        %State{process_groups: pg, monitors: monitors} = state
      ) do
    # Monitor this process if we're not already monitoring it
    {monitors, _new_monitor?} =
      if Map.has_key?(pg, pid) do
        {monitors, false}
      else
        ref = Process.monitor(pid)
        {Map.put(monitors, ref, pid), true}
      end

    pg = Map.put(pg, pid, group)
    {:reply, :ok, %{state | process_groups: pg, monitors: monitors}}
  end

  def handle_call({:new_group, name, type, action}, from, state) do
    handle_call({:new_group, name, type, action, state.root_synth_group}, from, state)
  end

  def handle_call(
        {:new_group, name, type, action, %Group{} = parent},
        _from,
        state
      ) do
    %{id: parent_id, in_bus: in_bus, out_bus: out_bus} = parent

    new_group = %Group{
      parent: parent,
      in_bus: in_bus,
      out_bus: out_bus,
      name: name,
      type: type,
      id: ID.next()
    }

    create_group(new_group.id, action, parent_id)

    {:reply, new_group, state}
  end

  def handle_call(
        {:new_group, name, type, action, out_bus, %Group{} = parent},
        _from,
        state
      ) do
    %{id: parent_id, out_bus: in_bus} = parent

    new_group = %Group{
      parent: parent,
      out_bus: out_bus,
      in_bus: in_bus,
      name: name,
      type: type,
      id: ID.next()
    }

    create_group(new_group.id, action, parent_id)

    {:reply, new_group, state}
  end

  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, default_state()}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  # Handle process death - clean up the group for that pid
  def handle_info(
        {:DOWN, ref, :process, _pid, _reason},
        %State{monitors: monitors, process_groups: pg} = state
      ) do
    case Map.pop(monitors, ref) do
      {nil, _} ->
        {:noreply, state}

      {pid, monitors} ->
        pg = Map.delete(pg, pid)
        {:noreply, %{state | monitors: monitors, process_groups: pg}}
    end
  end

  defp create_group(id, action, parent) do
    OSC.new_group(id, action, parent)
  end
end
