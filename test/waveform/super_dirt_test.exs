defmodule Waveform.SuperDirtTest do
  use ExUnit.Case, async: false

  alias Waveform.SuperDirt

  # Note: These tests work because config/test.exs uses NoOp transport
  # No actual OSC messages are sent to SuperDirt

  setup_all do
    # Manually start SuperDirt since application doesn't start in test mode
    unless Process.whereis(SuperDirt) do
      {:ok, _pid} = GenServer.start(SuperDirt, [], name: SuperDirt)
    end

    on_exit(fn ->
      if Process.whereis(SuperDirt), do: GenServer.stop(SuperDirt)
    end)

    :ok
  end

  describe "play/1" do
    test "plays a basic sound" do
      assert :ok = SuperDirt.play(s: "bd")
    end

    test "plays sound with multiple parameters" do
      assert :ok = SuperDirt.play(s: "cp", n: 3, speed: 1.5, gain: 0.8)
    end

    test "plays sound with effect parameters" do
      assert :ok = SuperDirt.play(s: "sn", room: 0.5, size: 0.8, delay: 0.3)
    end

    test "plays sound with custom orbit" do
      assert :ok = SuperDirt.play(s: "bd", orbit: 2)
    end

    test "plays sound with custom delta" do
      assert :ok = SuperDirt.play(s: "cp", delta: 0.5)
    end

    test "plays sound with pan parameter" do
      assert :ok = SuperDirt.play(s: "sn", pan: -0.5)
    end

    test "plays sound with begin and end parameters" do
      assert :ok = SuperDirt.play(s: "bd", begin: 0.25, end: 0.75)
    end

    test "accepts string sound names" do
      assert :ok = SuperDirt.play(s: "bass")
    end

    test "accepts atom sound names" do
      assert :ok = SuperDirt.play(s: :kick)
    end
  end

  describe "control messages" do
    test "hush stops all sounds" do
      assert :ok = SuperDirt.hush()
    end

    test "mute_all mutes all patterns" do
      assert :ok = SuperDirt.mute_all()
    end

    test "unmute_all unmutes all patterns" do
      assert :ok = SuperDirt.unmute_all()
    end

    test "unsolo_all clears solo state" do
      assert :ok = SuperDirt.unsolo_all()
    end
  end

  describe "set_cps/1" do
    setup do
      # Reset to default after each test
      on_exit(fn -> SuperDirt.set_cps(0.5625) end)
      :ok
    end

    test "sets cycles per second" do
      assert :ok = SuperDirt.set_cps(0.5)
    end

    test "sets cycles per second with float" do
      assert :ok = SuperDirt.set_cps(0.5625)
    end

    test "sets cycles per second with integer" do
      assert :ok = SuperDirt.set_cps(1)
    end

    test "sets tempo via BPM conversion" do
      # 120 BPM = 0.5 CPS
      assert :ok = SuperDirt.set_cps(120 / 240)
    end
  end

  describe "cycle tracking" do
    test "increments cycle counter on each play" do
      # Get initial state
      initial_state = :sys.get_state(SuperDirt)
      initial_cycle = initial_state.cycle

      # Play a sound
      SuperDirt.play(s: "bd")

      # Verify cycle incremented
      new_state = :sys.get_state(SuperDirt)
      assert new_state.cycle == initial_cycle + 1.0
    end

    test "cycle counter increments multiple times" do
      initial_state = :sys.get_state(SuperDirt)
      initial_cycle = initial_state.cycle

      # Play multiple sounds
      SuperDirt.play(s: "bd")
      SuperDirt.play(s: "cp")
      SuperDirt.play(s: "sn")

      # Verify cycle incremented 3 times
      new_state = :sys.get_state(SuperDirt)
      assert new_state.cycle == initial_cycle + 3.0
    end
  end

  describe "state management" do
    test "default CPS is 0.5625 (135 BPM)" do
      state = :sys.get_state(SuperDirt)
      assert state.cps == 0.5625
    end

    test "default port is 57120" do
      state = :sys.get_state(SuperDirt)
      assert state.port == 57_120
    end

    test "default host is localhost" do
      state = :sys.get_state(SuperDirt)
      assert state.host == ~c"127.0.0.1"
    end

    test "CPS can be updated" do
      SuperDirt.set_cps(1.0)
      state = :sys.get_state(SuperDirt)
      assert state.cps == 1.0

      # Reset to default
      SuperDirt.set_cps(0.5625)
    end
  end
end
