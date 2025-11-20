defmodule Waveform.OSC.Node.IDTest do
  use ExUnit.Case, async: true

  alias Waveform.OSC.Node.ID

  describe "Agent-based counter" do
    setup do
      # Start with unique name for parallel testing
      name = :"id_counter_#{:rand.uniform(1_000_000)}"
      {:ok, pid} = Agent.start_link(fn -> 100 end, name: name)

      on_exit(fn ->
        if Process.alive?(pid), do: Agent.stop(pid)
      end)

      %{pid: pid, name: name}
    end

    test "starts with initial value", %{name: name} do
      assert 100 == Agent.get(name, & &1)
    end

    test "increments atomically", %{name: name} do
      # Next should return incremented value and update state
      id1 = Agent.get_and_update(name, fn id -> {id + 1, id + 1} end)
      id2 = Agent.get_and_update(name, fn id -> {id + 1, id + 1} end)
      id3 = Agent.get_and_update(name, fn id -> {id + 1, id + 1} end)

      assert id1 == 101
      assert id2 == 102
      assert id3 == 103
    end

    test "state returns current value without incrementing", %{name: name} do
      current = Agent.get(name, & &1)
      # Same value on second call
      assert current == Agent.get(name, & &1)
    end
  end

  describe "production usage with singleton" do
    test "next/0 increments and returns value" do
      # Start the singleton (or reuse if already started)
      unless Process.whereis(ID), do: ID.start_link(100)

      # Get sequential IDs
      id1 = ID.next()
      id2 = ID.next()
      id3 = ID.next()

      # IDs should be sequential (but we don't know the starting value
      # since other tests may have incremented it)
      assert id2 == id1 + 1
      assert id3 == id2 + 1
    end

    test "state/0 returns current value" do
      # Start the singleton (or reuse if already started)
      unless Process.whereis(ID), do: ID.start_link(100)

      current = ID.state()
      assert is_integer(current)

      # After incrementing, state should increase
      ID.next()
      assert ID.state() == current + 1
    end
  end
end
