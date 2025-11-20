defmodule Waveform.OSC.Node.ID do
  @moduledoc """
  Simple counter for allocating unique node IDs.

  Uses Agent for lightweight state management - just an incrementing counter.
  No need for GenServer overhead when all we're doing is incrementing an integer.
  """
  use Agent

  @doc """
  Start the node ID counter with an optional initial value.

  ## Examples

      {:ok, _pid} = Node.ID.start_link(100)
  """
  def start_link(initial_id \\ 0) do
    Agent.start_link(fn -> initial_id end, name: __MODULE__)
  end

  @doc """
  Get the next available node ID.

  Returns the next ID and increments the counter atomically.

  ## Examples

      Node.ID.next()  # => 100
      Node.ID.next()  # => 101
  """
  def next do
    Agent.get_and_update(__MODULE__, fn id -> {id + 1, id + 1} end)
  end

  @doc """
  Get the current state of the counter without incrementing.

  Useful for debugging or testing.
  """
  def state do
    Agent.get(__MODULE__, & &1)
  end

  defmodule State do
    @moduledoc """
    Legacy state struct for backwards compatibility with tests.

    The Agent stores just an integer now, but this struct wrapper
    is kept so existing test code doesn't break.
    """
    defstruct(current_id: 0)
  end
end
