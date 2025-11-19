defmodule Waveform.OSC.Group do
  @moduledoc """
  Manages group allocation and hierarchy for SuperCollider.

  Groups organize synths into a tree structure. This module provides basic
  group management with per-process group stacks for scoped group activation.

  Process monitors ensure that dead processes don't leak memory in the
  per-process group tracking.
  """
  use GenServer

  @me __MODULE__
  alias __MODULE__

  alias Waveform.OSC.Node.ID
  alias Waveform.OSC

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
    defstruct(
      root_group: %Group{id: 1, name: :root},
      root_synth_group: nil,
      # Map of pid => [group stack], with monitors to clean up dead processes
      active_synth_group: %{},
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

  def restore_synth_group(pid) when is_pid(pid) do
    GenServer.call(@me, {:restore_synth_group, pid})
  end

  def activate_synth_group(pid, %Group{} = g) when is_pid(pid) do
    GenServer.call(@me, {:activate_group, pid, g})
  end

  def synth_group(pid) do
    %State{active_synth_group: asg, root_synth_group: rsg} = state()

    synth_group = (asg[pid] || []) |> List.first()

    synth_group || rsg
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

  def handle_call({:restore_synth_group, pid}, _from, %State{active_synth_group: asg} = state) do
    [_ | t] = asg[pid] || []
    asg = if t == [], do: Map.delete(asg, pid), else: Map.put(asg, pid, t)

    # If we just removed the last group for this pid, demonitor it
    state =
      if t == [] do
        demonitor_pid(state, pid)
      else
        state
      end

    {:reply, {:ok, List.first(t)}, %{state | active_synth_group: asg}}
  end

  def handle_call({:root_synth_group}, _from, state) do
    group = %Group{type: :synth, name: :root_synth_group, id: ID.next()}

    create_group(group.id, :head, state.root_group.id)

    {:reply, :ok, %{state | root_synth_group: group}}
  end

  def handle_call(
        {:activate_group, pid, %Group{} = g},
        _from,
        %State{active_synth_group: asg, monitors: monitors} = state
      ) do
    # Monitor this process if we're not already monitoring it
    {state, monitors} =
      if Map.has_key?(asg, pid) do
        {state, monitors}
      else
        ref = Process.monitor(pid)
        {state, Map.put(monitors, ref, pid)}
      end

    pid_groups = asg[pid] || []
    asg = Map.put(asg, pid, [g | pid_groups])
    {:reply, :ok, %{state | active_synth_group: asg, monitors: monitors}}
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

  # Handle process death - clean up the group stack for that pid
  def handle_info(
        {:DOWN, ref, :process, _pid, _reason},
        %State{monitors: monitors, active_synth_group: asg} = state
      ) do
    case Map.pop(monitors, ref) do
      {nil, _} ->
        {:noreply, state}

      {pid, monitors} ->
        asg = Map.delete(asg, pid)
        {:noreply, %{state | monitors: monitors, active_synth_group: asg}}
    end
  end

  defp create_group(id, action, parent) do
    OSC.new_group(id, action, parent)
  end

  defp demonitor_pid(state, pid) do
    # Find and remove the monitor for this pid
    case Enum.find(state.monitors, fn {_ref, p} -> p == pid end) do
      nil ->
        state

      {ref, _pid} ->
        Process.demonitor(ref, [:flush])
        %{state | monitors: Map.delete(state.monitors, ref)}
    end
  end
end
