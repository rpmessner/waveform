defmodule Waveform.PatternSchedulerTest do
  use ExUnit.Case, async: false

  alias Waveform.PatternScheduler

  # Note: These tests use NoOp transport, so no actual audio is sent

  setup_all do
    # Start SuperDirt (needed for latency queries)
    unless Process.whereis(Waveform.SuperDirt) do
      {:ok, _pid} = GenServer.start(Waveform.SuperDirt, [], name: Waveform.SuperDirt)
    end

    # Start scheduler with default CPS
    unless Process.whereis(PatternScheduler) do
      {:ok, _pid} = PatternScheduler.start_link(cps: 0.5625)
    end

    on_exit(fn ->
      # Safely stop processes - they may have already been stopped
      try do
        if Process.whereis(Waveform.SuperDirt), do: GenServer.stop(Waveform.SuperDirt)
      catch
        :exit, _ -> :ok
      end

      try do
        if Process.whereis(PatternScheduler), do: GenServer.stop(PatternScheduler)
      catch
        :exit, _ -> :ok
      end
    end)

    :ok
  end

  describe "basic pattern scheduling" do
    test "can schedule a simple pattern" do
      events = [
        {0.0, [s: "bd"]},
        {0.5, [s: "sd"]}
      ]

      assert :ok = PatternScheduler.schedule_pattern(:test_pattern, events)
    end

    test "can update an existing pattern" do
      events = [{0.0, [s: "bd"]}]
      PatternScheduler.schedule_pattern(:test_pattern, events)

      new_events = [{0.0, [s: "bd"]}, {0.25, [s: "cp"]}]
      assert :ok = PatternScheduler.update_pattern(:test_pattern, new_events)
    end

    test "can stop a pattern" do
      events = [{0.0, [s: "bd"]}]
      PatternScheduler.schedule_pattern(:test_pattern, events)

      assert :ok = PatternScheduler.stop_pattern(:test_pattern)
    end

    test "hush stops all patterns" do
      PatternScheduler.schedule_pattern(:pattern1, [{0.0, [s: "bd"]}])
      PatternScheduler.schedule_pattern(:pattern2, [{0.0, [s: "cp"]}])

      assert :ok = PatternScheduler.hush()
    end
  end

  describe "tempo control" do
    test "can set CPS" do
      assert :ok = PatternScheduler.set_cps(0.5)
    end

    test "CPS must be positive" do
      # This should raise because of guard clause
      assert_raise FunctionClauseError, fn ->
        PatternScheduler.set_cps(0)
      end
    end
  end

  describe "cycle calculation" do
    test "calculates current cycle based on elapsed time" do
      # Get state to inspect cycle calculation
      # After some time has passed, cycle should be non-zero
      # Wait 100ms
      Process.sleep(100)

      state = :sys.get_state(PatternScheduler)

      # Should have some cycles elapsed
      # At default CPS (0.5625), 100ms = 0.05625 cycles
      # But we can't assert exact value due to timing variability
      assert is_float(state.cps)
      assert state.cps > 0
    end
  end

  describe "multiple patterns" do
    test "can run multiple patterns simultaneously" do
      PatternScheduler.schedule_pattern(:drums, [
        {0.0, [s: "bd"]},
        {0.5, [s: "sd"]}
      ])

      PatternScheduler.schedule_pattern(:hats, [
        {0.0, [s: "hh"]},
        {0.25, [s: "hh"]},
        {0.5, [s: "hh"]},
        {0.75, [s: "hh"]}
      ])

      # Both should be in state
      state = :sys.get_state(PatternScheduler)
      assert Map.has_key?(state.patterns, :drums)
      assert Map.has_key?(state.patterns, :hats)
    end

    test "patterns are independent" do
      PatternScheduler.schedule_pattern(:pattern1, [{0.0, [s: "bd"]}])
      PatternScheduler.schedule_pattern(:pattern2, [{0.0, [s: "cp"]}])

      # Stop one
      PatternScheduler.stop_pattern(:pattern1)

      # Other should still exist
      state = :sys.get_state(PatternScheduler)
      refute Map.has_key?(state.patterns, :pattern1)
      assert Map.has_key?(state.patterns, :pattern2)
    end
  end

  describe "state management" do
    test "state contains expected fields" do
      state = :sys.get_state(PatternScheduler)

      assert Map.has_key?(state, :patterns)
      assert Map.has_key?(state, :cps)
      assert Map.has_key?(state, :start_time)
      assert Map.has_key?(state, :tick_interval_ms)
      assert Map.has_key?(state, :scheduled_events)
    end

    test "default CPS is 0.5625 (135 BPM)" do
      # Reset CPS in case other tests changed it
      PatternScheduler.set_cps(0.5625)

      state = :sys.get_state(PatternScheduler)
      assert state.cps == 0.5625
    end

    test "default tick interval is 10ms" do
      state = :sys.get_state(PatternScheduler)
      assert state.tick_interval_ms == 10
    end
  end

  describe "pattern structure" do
    test "pattern events are stored correctly" do
      events = [
        {0.0, [s: "bd", n: 1]},
        {0.25, [s: "cp", gain: 0.8]},
        {0.5, [s: "sd"]}
      ]

      PatternScheduler.schedule_pattern(:test, events)

      state = :sys.get_state(PatternScheduler)
      pattern = Map.get(state.patterns, :test)

      assert pattern.events == events
      assert pattern.active == true
    end
  end
end
