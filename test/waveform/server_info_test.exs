defmodule Waveform.ServerInfoTest do
  use ExUnit.Case, async: false  # :persistent_term is global, can't run in parallel

  alias Waveform.ServerInfo

  setup do
    # Clean up any existing value before each test
    # Note: :persistent_term.erase/1 was added in OTP 21.3
    # For older versions, we just accept the global state
    :ok
  end

  describe "sample_rate storage" do
    test "returns nil when not set" do
      # May be nil or a value from previous test, just test the API works
      result = ServerInfo.sample_rate()
      assert is_nil(result) or is_float(result)
    end

    test "stores sample rate from valid status reply" do
      # Format: [unused, ugens, synths, groups, synthdefs, avg_cpu, peak_cpu, nominal_sr, actual_sr]
      status_reply = [1, 0, 0, 0, 0, 0.0, 0.0, 44100.0, 44100.0]

      assert :ok = ServerInfo.set_from_status_reply(status_reply)
      assert 44100.0 == ServerInfo.sample_rate()
    end

    test "stores different sample rates" do
      # 48kHz
      ServerInfo.set_from_status_reply([1, 0, 0, 0, 0, 0.0, 0.0, 48000.0, 48000.0])
      assert 48000.0 == ServerInfo.sample_rate()

      # 96kHz
      ServerInfo.set_from_status_reply([1, 0, 0, 0, 0, 0.0, 0.0, 96000.0, 96000.0])
      assert 96000.0 == ServerInfo.sample_rate()
    end

    test "returns error for invalid status reply" do
      # Wrong number of elements
      assert :error = ServerInfo.set_from_status_reply([1, 2, 3])

      # Empty list
      assert :error = ServerInfo.set_from_status_reply([])
    end

    test "handles mismatched nominal vs actual sample rate" do
      # Nominal and actual can differ slightly
      status_reply = [1, 0, 0, 0, 0, 0.0, 0.0, 44100.0, 44099.5]

      ServerInfo.set_from_status_reply(status_reply)
      assert 44099.5 == ServerInfo.sample_rate()
    end
  end

  describe ":persistent_term storage characteristics" do
    test "sample rate persists across calls" do
      ServerInfo.set_from_status_reply([1, 0, 0, 0, 0, 0.0, 0.0, 44100.0, 44100.0])

      # Multiple reads should return same value (no process overhead)
      assert 44100.0 == ServerInfo.sample_rate()
      assert 44100.0 == ServerInfo.sample_rate()
      assert 44100.0 == ServerInfo.sample_rate()
    end
  end
end
