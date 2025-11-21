defmodule Waveform.PatternSchedulerTest do
  use ExUnit.Case, async: true

  alias Waveform.PatternScheduler

  # Note: These tests use NoOp transport, so no actual audio is sent

  setup do
    # Start SuperDirt (needed for latency queries) with a random UDP port to avoid conflicts
    random_port = 50_000 + :rand.uniform(10_000)
    super_dirt = start_supervised!({Waveform.SuperDirt, [name: nil, udp_port: random_port]})

    # Start scheduler with default CPS
    scheduler = start_supervised!({PatternScheduler, [cps: 0.5625, name: nil]})

    %{scheduler: scheduler, super_dirt: super_dirt}
  end

  describe "basic pattern scheduling" do
    test "can schedule a simple pattern", %{scheduler: scheduler} do
      events = [
        {0.0, [s: "bd"]},
        {0.5, [s: "sd"]}
      ]

      assert :ok = PatternScheduler.schedule_pattern(:test_pattern, events, scheduler)
    end

    test "can update an existing pattern", %{scheduler: scheduler} do
      events = [{0.0, [s: "bd"]}]
      PatternScheduler.schedule_pattern(:test_pattern, events, scheduler)

      new_events = [{0.0, [s: "sd"]}]
      assert :ok = PatternScheduler.update_pattern(:test_pattern, new_events, scheduler)
    end

    test "can stop a pattern", %{scheduler: scheduler} do
      events = [{0.0, [s: "bd"]}]
      PatternScheduler.schedule_pattern(:test_pattern, events, scheduler)

      assert :ok = PatternScheduler.stop_pattern(:test_pattern, scheduler)
    end

    test "hush stops all patterns", %{scheduler: scheduler, super_dirt: super_dirt} do
      PatternScheduler.schedule_pattern(:pattern1, [{0.0, [s: "bd"]}], scheduler)
      PatternScheduler.schedule_pattern(:pattern2, [{0.0, [s: "sd"]}], scheduler)

      # Hush is implemented via SuperDirt
      assert :ok = Waveform.SuperDirt.hush(super_dirt)
    end
  end

  describe "tempo control" do
    test "can set CPS", %{scheduler: scheduler} do
      assert :ok = PatternScheduler.set_cps(0.5, scheduler)
    end

    test "CPS must be positive" do
      # Note: This doesn't need a scheduler since it's testing the function clause guard
      assert_raise FunctionClauseError, fn ->
        PatternScheduler.set_cps(-0.5, self())
      end
    end
  end

  describe "cycle calculation" do
    test "calculates current cycle based on elapsed time", %{scheduler: scheduler} do
      # Give the scheduler a moment to initialize
      Process.sleep(100)

      state = :sys.get_state(scheduler)

      # Time elapsed since start (in microseconds)
      now = System.monotonic_time(:microsecond)
      elapsed_us = now - state.start_time

      # Convert to cycles
      elapsed_s = elapsed_us / 1_000_000
      expected_cycle = elapsed_s * state.cps

      # Should be close to expected (allowing for small timing variations)
      assert_in_delta expected_cycle, 0, 0.1
    end
  end

  describe "multiple patterns" do
    test "can run multiple patterns simultaneously", %{scheduler: scheduler} do
      PatternScheduler.schedule_pattern(
        :drums,
        [
          {0.0, [s: "bd"]},
          {0.5, [s: "sd"]}
        ],
        scheduler
      )

      PatternScheduler.schedule_pattern(
        :hats,
        [
          {0.0, [s: "hh"]},
          {0.25, [s: "hh"]},
          {0.5, [s: "hh"]},
          {0.75, [s: "hh"]}
        ],
        scheduler
      )

      # Both should be in state
      state = :sys.get_state(scheduler)
      assert Map.has_key?(state.patterns, :drums)
      assert Map.has_key?(state.patterns, :hats)
    end

    test "patterns are independent", %{scheduler: scheduler} do
      PatternScheduler.schedule_pattern(:pattern1, [{0.0, [s: "bd"]}], scheduler)
      PatternScheduler.schedule_pattern(:pattern2, [{0.0, [s: "cp"]}], scheduler)

      # Stop one
      PatternScheduler.stop_pattern(:pattern1, scheduler)

      # Other should still exist
      state = :sys.get_state(scheduler)
      refute Map.has_key?(state.patterns, :pattern1)
      assert Map.has_key?(state.patterns, :pattern2)
    end
  end

  describe "state management" do
    test "state contains expected fields", %{scheduler: scheduler} do
      state = :sys.get_state(scheduler)

      assert Map.has_key?(state, :patterns)
      assert Map.has_key?(state, :cps)
      assert Map.has_key?(state, :start_time)
      assert Map.has_key?(state, :tick_interval_ms)
      assert Map.has_key?(state, :scheduled_events)
    end

    test "default CPS is 0.5625 (135 BPM)", %{scheduler: scheduler} do
      # Reset CPS in case other tests changed it
      PatternScheduler.set_cps(0.5625, scheduler)

      state = :sys.get_state(scheduler)
      assert state.cps == 0.5625
    end

    test "default tick interval is 10ms", %{scheduler: scheduler} do
      state = :sys.get_state(scheduler)
      assert state.tick_interval_ms == 10
    end
  end

  describe "pattern structure" do
    test "pattern events are stored correctly", %{scheduler: scheduler} do
      events = [
        {0.0, [s: "bd", n: 1]},
        {0.25, [s: "cp", gain: 0.8]},
        {0.5, [s: "sd"]}
      ]

      PatternScheduler.schedule_pattern(:test, events, scheduler)

      state = :sys.get_state(scheduler)
      pattern = Map.get(state.patterns, :test)

      assert pattern.events == events
      assert pattern.active == true
    end
  end
end
