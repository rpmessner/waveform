defmodule Waveform.SynthTest do
  use ExUnit.Case, async: false  # Uses global Node.ID and Group singletons

  alias Waveform.Synth
  alias Waveform.OSC
  alias Waveform.OSC.Node
  alias Waveform.OSC.Group

  # Note: These tests work because config/test.exs uses NoOp transport
  # No actual OSC messages are sent to SuperCollider

  setup_all do
    # Manually start the required processes since application doesn't start in test mode
    # Only start if not already running (another test may have started them)
    unless Process.whereis(OSC), do: GenServer.start(OSC, nil, name: OSC)
    unless Process.whereis(Node.ID), do: Node.ID.start_link(100)
    unless Process.whereis(Node), do: GenServer.start(Node, %Node.State{}, name: Node)
    unless Process.whereis(Group), do: GenServer.start(Group, %Group.State{}, name: Group)

    # Initialize the root synth group (idempotent - safe to call multiple times)
    Group.setup()

    on_exit(fn ->
      if Process.whereis(OSC), do: GenServer.stop(OSC)
      if Process.whereis(Node.ID), do: Agent.stop(Node.ID)
      if Process.whereis(Node), do: GenServer.stop(Node)
      if Process.whereis(Group), do: GenServer.stop(Group)
    end)

    :ok
  end

  describe "trigger/3" do
    test "triggers synth with basic parameters" do
      result = Synth.trigger("test_synth", note: 60, amp: 0.5)

      assert %{node_id: node_id, group_id: group_id} = result
      assert is_integer(node_id)
      assert is_integer(group_id)
    end

    test "triggers synth with no parameters" do
      result = Synth.trigger("kick")

      assert %{node_id: _, group_id: _} = result
    end

    test "triggers synth with custom node and group IDs" do
      result = Synth.trigger("snare", [amp: 0.8], node_id: 1001, group_id: 10)

      assert result.node_id == 1001
      assert result.group_id == 10
    end

    test "triggers synth with custom action" do
      result = Synth.trigger("bass", [note: 48], action: :tail)

      assert %{node_id: _, group_id: _} = result
    end

    test "filters out non-numeric parameters" do
      # Should silently ignore invalid parameters
      result = Synth.trigger("synth", [
        note: 60,           # Valid: number
        amp: 0.5,           # Valid: number
        invalid: "string",  # Invalid: not a number
        freq: 440.0         # Valid: float
      ])

      assert %{node_id: _, group_id: _} = result
    end

    test "handles charlist synth names" do
      result = Synth.trigger(~c"test", note: 60)

      assert %{node_id: _, group_id: _} = result
    end
  end

  describe "play/2" do
    test "plays MIDI note with default synth" do
      result = Synth.play(60)

      assert %{node_id: _, group_id: _} = result
    end

    test "plays MIDI note with specified synth" do
      result = Synth.play(64, synth: "piano")

      assert %{node_id: _, group_id: _} = result
    end

    test "plays MIDI note with additional parameters" do
      result = Synth.play(67, synth: "saw", amp: 0.7, cutoff: 1000)

      assert %{node_id: _, group_id: _} = result
    end

    test "plays float MIDI note" do
      result = Synth.play(60.5, synth: "test")

      assert %{node_id: _, group_id: _} = result
    end
  end

  describe "play/2 with Harmony (if available)" do
    test "plays note name if Harmony is loaded" do
      if Code.ensure_loaded?(Harmony.Note) do
        result = Synth.play("c4", synth: "piano")
        assert %{node_id: _, group_id: _} = result
      else
        # Skip test if Harmony not available
        :ok
      end
    end

    test "raises error for note name without Harmony" do
      unless Code.ensure_loaded?(Harmony.Note) do
        assert_raise RuntimeError, ~r/Harmony library not available/, fn ->
          Synth.play("c4", synth: "test")
        end
      else
        # Skip if Harmony is loaded
        :ok
      end
    end
  end
end
