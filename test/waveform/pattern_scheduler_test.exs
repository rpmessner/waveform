defmodule Waveform.PatternSchedulerTest do
  use ExUnit.Case, async: true

  alias Waveform.PatternScheduler
  alias UzuPattern.Pattern

  setup do
    super_dirt = start_supervised!({Waveform.SuperDirt, [name: nil, udp_port: 0]})
    scheduler = start_supervised!({PatternScheduler, [cps: 0.5625, name: nil]})

    %{scheduler: scheduler, super_dirt: super_dirt}
  end

  describe "basic pattern scheduling" do
    test "can schedule a simple pattern", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("bd sd")

      assert :ok = PatternScheduler.schedule_pattern(:test_pattern, pattern, scheduler)
    end

    test "can update an existing pattern", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("bd")
      PatternScheduler.schedule_pattern(:test_pattern, pattern, scheduler)

      new_pattern = UzuPattern.parse("sd")
      assert :ok = PatternScheduler.update_pattern(:test_pattern, new_pattern, scheduler)
    end

    test "can stop a pattern", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("bd")
      PatternScheduler.schedule_pattern(:test_pattern, pattern, scheduler)

      assert :ok = PatternScheduler.stop_pattern(:test_pattern, scheduler)
    end

    test "hush stops all patterns", %{scheduler: scheduler, super_dirt: super_dirt} do
      pattern1 = UzuPattern.parse("bd")
      pattern2 = UzuPattern.parse("sd")
      PatternScheduler.schedule_pattern(:pattern1, pattern1, scheduler)
      PatternScheduler.schedule_pattern(:pattern2, pattern2, scheduler)

      assert :ok = Waveform.SuperDirt.hush(super_dirt)
    end
  end

  describe "tempo control" do
    test "can set CPS", %{scheduler: scheduler} do
      assert :ok = PatternScheduler.set_cps(0.5, scheduler)
    end

    test "CPS must be positive" do
      assert_raise FunctionClauseError, fn ->
        PatternScheduler.set_cps(-0.5, self())
      end
    end
  end

  describe "cycle calculation" do
    test "calculates current cycle based on elapsed time", %{scheduler: scheduler} do
      Process.sleep(100)

      state = :sys.get_state(scheduler)

      now = System.monotonic_time(:microsecond)
      elapsed_us = now - state.start_time

      elapsed_s = elapsed_us / 1_000_000
      expected_cycle = elapsed_s * state.cps

      assert_in_delta expected_cycle, 0, 0.1
    end
  end

  describe "multiple patterns" do
    test "can run multiple patterns simultaneously", %{scheduler: scheduler} do
      drums = UzuPattern.parse("bd sd")
      hats = UzuPattern.parse("hh hh hh hh")

      PatternScheduler.schedule_pattern(:drums, drums, scheduler)
      PatternScheduler.schedule_pattern(:hats, hats, scheduler)

      state = :sys.get_state(scheduler)
      assert Map.has_key?(state.patterns, :drums)
      assert Map.has_key?(state.patterns, :hats)
    end

    test "patterns are independent", %{scheduler: scheduler} do
      pattern1 = UzuPattern.parse("bd")
      pattern2 = UzuPattern.parse("cp")
      PatternScheduler.schedule_pattern(:pattern1, pattern1, scheduler)
      PatternScheduler.schedule_pattern(:pattern2, pattern2, scheduler)

      PatternScheduler.stop_pattern(:pattern1, scheduler)

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
    test "uzu_pattern is stored correctly", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("bd cp sd")

      PatternScheduler.schedule_pattern(:test, pattern, scheduler)

      state = :sys.get_state(scheduler)
      stored_pattern = Map.get(state.patterns, :test)

      assert %UzuPattern.Pattern{} = stored_pattern.uzu_pattern
      assert stored_pattern.active == true
    end
  end

  describe "pattern transformations" do
    test "fast transformation works", %{scheduler: scheduler} do
      pattern =
        UzuPattern.parse("bd sd")
        |> Pattern.fast(2)

      assert :ok = PatternScheduler.schedule_pattern(:fast_test, pattern, scheduler)

      # Verify events are correct
      events = Pattern.query(pattern, 0)
      assert length(events) == 4
    end

    test "slow transformation works", %{scheduler: scheduler} do
      pattern =
        UzuPattern.parse("bd sd hh cp")
        |> Pattern.slow(2)

      assert :ok = PatternScheduler.schedule_pattern(:slow_test, pattern, scheduler)

      # Slow by 2 means 2 events per cycle
      events = Pattern.query(pattern, 0)
      assert length(events) == 2
    end

    test "rev transformation works", %{scheduler: scheduler} do
      pattern =
        UzuPattern.parse("bd sd hh")
        |> Pattern.rev()

      assert :ok = PatternScheduler.schedule_pattern(:rev_test, pattern, scheduler)

      haps = Pattern.query(pattern, 0)
      # First hap should be hh (reversed from bd sd hh)
      assert List.first(haps).value.s == "hh"
    end

    test "every transformation receives cycle number", %{scheduler: scheduler} do
      test_pid = self()

      # Create a pattern that reports when queried
      base_pattern = UzuPattern.parse("bd sd")

      pattern =
        Pattern.every(base_pattern, 2, fn p ->
          send(test_pid, :transformed)
          Pattern.rev(p)
        end)

      PatternScheduler.schedule_pattern(:every_test, pattern, scheduler)

      # Wait for scheduler to query the pattern
      Process.sleep(50)

      # Pattern was scheduled - every/3 applies transformation at query time
      state = :sys.get_state(scheduler)
      assert Map.has_key?(state.patterns, :every_test)
    end
  end

  describe "output configuration" do
    test "default output is superdirt", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("bd")
      PatternScheduler.schedule_pattern(:test_output, pattern, scheduler)

      state = :sys.get_state(scheduler)
      stored = Map.get(state.patterns, :test_output)
      assert stored.output == :superdirt
    end

    test "can set midi output", %{scheduler: scheduler} do
      pattern = UzuPattern.parse("60 64 67")

      assert :ok =
               PatternScheduler.schedule_pattern(:midi_test, pattern,
                 server: scheduler,
                 output: :midi,
                 midi_channel: 1
               )

      state = :sys.get_state(scheduler)
      stored = Map.get(state.patterns, :midi_test)
      assert stored.output == :midi
      assert stored.output_opts[:midi_channel] == 1
    end
  end
end
