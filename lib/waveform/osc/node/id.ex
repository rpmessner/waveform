defmodule Waveform.OSC.Node.ID do
  @moduledoc """
  Simple counter for allocating unique node IDs.

  Uses Agent for lightweight state management - just an incrementing counter.
  No need for GenServer overhead when all we're doing is incrementing an integer.
  """
  use Agent

  @doc """
  Start the node ID counter with an optional initial value.

  ## Options

  - `:initial_id` - Starting ID value (default: 0)
  - `:name` - Process name (default: #{__MODULE__})

  ## Examples

      {:ok, _pid} = Node.ID.start_link(100)
      {:ok, _pid} = Node.ID.start_link(initial_id: 100, name: MyCounter)
  """
  def start_link(opts \\ [])

  def start_link(initial_id) when is_integer(initial_id) do
    start_link(initial_id: initial_id)
  end

  def start_link(opts) when is_list(opts) do
    initial_id = Keyword.get(opts, :initial_id, 0)
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> initial_id end, name: name)
  end

  @doc """
  Get the next available node ID.

  Returns the next ID and increments the counter atomically.

  ## Examples

      Node.ID.next()  # => 100
      Node.ID.next()  # => 101
  """
  def next(server \\ __MODULE__) do
    Agent.get_and_update(server, fn id -> {id + 1, id + 1} end)
  end

  @doc """
  Get the current state of the counter without incrementing.

  Useful for debugging or testing.
  """
  def state(server \\ __MODULE__) do
    Agent.get(server, & &1)
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
