defmodule Waveform.SuperDirtTest do
  use ExUnit.Case, async: true

  alias Waveform.SuperDirt

  # Note: These tests work because config/test.exs uses NoOp transport
  # No actual OSC messages are sent to SuperDirt

  setup do
    # Start SuperDirt with port 0 to let OS assign an available port
    super_dirt = start_supervised!({SuperDirt, [name: nil, udp_port: 0]})

    %{super_dirt: super_dirt}
  end

  describe "play/1" do
    test "plays a basic sound", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "bd"], super_dirt)
    end

    test "plays sound with multiple parameters", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "cp", n: 3, speed: 1.5, gain: 0.8], super_dirt)
    end

    test "plays sound with effect parameters", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "sn", room: 0.5, size: 0.8, delay: 0.3], super_dirt)
    end

    test "plays sound with custom orbit", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "bd", orbit: 2], super_dirt)
    end

    test "plays sound with custom delta", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "cp", delta: 0.5], super_dirt)
    end

    test "plays sound with pan parameter", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "sn", pan: -0.5], super_dirt)
    end

    test "plays sound with begin and end parameters", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "bd", begin: 0.25, end: 0.75], super_dirt)
    end

    test "accepts string sound names", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: "bass"], super_dirt)
    end

    test "accepts atom sound names", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.play([s: :kick], super_dirt)
    end
  end

  describe "control messages" do
    test "hush stops all sounds", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.hush(super_dirt)
    end

    test "mute_all mutes all patterns", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.mute_all(super_dirt)
    end

    test "unmute_all unmutes all patterns", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.unmute_all(super_dirt)
    end

    test "unsolo_all clears solo state", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.unsolo_all(super_dirt)
    end
  end

  describe "set_cps/1" do
    test "sets cycles per second", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_cps(0.5, super_dirt)
    end

    test "sets cycles per second with float", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_cps(0.5625, super_dirt)
    end

    test "sets cycles per second with integer", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_cps(1, super_dirt)
    end

    test "sets tempo via BPM conversion", %{super_dirt: super_dirt} do
      # 120 BPM = 0.5 CPS
      assert :ok = SuperDirt.set_cps(120 / 240, super_dirt)
    end
  end

  describe "cycle tracking" do
    test "increments cycle counter on each play", %{super_dirt: super_dirt} do
      # Get initial state
      initial_state = :sys.get_state(super_dirt)
      initial_cycle = initial_state.cycle

      # Play a sound
      SuperDirt.play([s: "bd"], super_dirt)

      # Verify cycle incremented
      new_state = :sys.get_state(super_dirt)
      assert new_state.cycle == initial_cycle + 1.0
    end

    test "cycle counter increments multiple times", %{super_dirt: super_dirt} do
      initial_state = :sys.get_state(super_dirt)
      initial_cycle = initial_state.cycle

      # Play multiple sounds
      SuperDirt.play([s: "bd"], super_dirt)
      SuperDirt.play([s: "cp"], super_dirt)
      SuperDirt.play([s: "sn"], super_dirt)

      # Verify cycle incremented 3 times
      new_state = :sys.get_state(super_dirt)
      assert new_state.cycle == initial_cycle + 3.0
    end
  end

  describe "state management" do
    test "default CPS is 0.5625 (135 BPM)", %{super_dirt: super_dirt} do
      state = :sys.get_state(super_dirt)
      assert state.cps == 0.5625
    end

    test "default port is 57120", %{super_dirt: super_dirt} do
      state = :sys.get_state(super_dirt)
      assert state.port == 57_120
    end

    test "default host is localhost", %{super_dirt: super_dirt} do
      state = :sys.get_state(super_dirt)
      assert state.host == ~c"127.0.0.1"
    end

    test "default latency is 0.02 (20ms)", %{super_dirt: super_dirt} do
      state = :sys.get_state(super_dirt)
      assert state.latency == 0.02
    end

    test "CPS can be updated", %{super_dirt: super_dirt} do
      SuperDirt.set_cps(1.0, super_dirt)
      state = :sys.get_state(super_dirt)
      assert state.cps == 1.0
    end
  end

  describe "latency management" do
    test "get_latency returns current latency", %{super_dirt: super_dirt} do
      assert SuperDirt.get_latency(super_dirt) == 0.02
    end

    test "set_latency updates latency", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_latency(0.05, super_dirt)
      assert SuperDirt.get_latency(super_dirt) == 0.05
    end

    test "set_latency accepts float values", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_latency(0.015, super_dirt)
      assert SuperDirt.get_latency(super_dirt) == 0.015
    end

    test "set_latency accepts integer values", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_latency(1, super_dirt)
      assert SuperDirt.get_latency(super_dirt) == 1
    end

    test "set_latency accepts zero latency", %{super_dirt: super_dirt} do
      assert :ok = SuperDirt.set_latency(0, super_dirt)
      assert SuperDirt.get_latency(super_dirt) == 0
    end

    test "latency persists across play calls", %{super_dirt: super_dirt} do
      SuperDirt.set_latency(0.1, super_dirt)
      SuperDirt.play([s: "bd"], super_dirt)
      assert SuperDirt.get_latency(super_dirt) == 0.1
    end
  end
end
