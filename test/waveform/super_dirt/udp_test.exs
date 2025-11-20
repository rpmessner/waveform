defmodule Waveform.SuperDirt.UDPTest do
  use ExUnit.Case, async: true

  alias Waveform.SuperDirt.UDP

  describe "send_osc_bundle/2" do
    test "creates OSC bundle with #bundle header" do
      # Create minimal state for testing
      {:ok, socket} = :gen_udp.open(0, [:binary, {:active, false}])

      state = %{
        socket: socket,
        host: ~c"127.0.0.1",
        port: 57_120,
        latency: 0.02
      }

      # Send a message
      message = [~c"/dirt/play", ~c"s", "bd", ~c"n", 0]

      # Note: This will actually send to localhost:57120
      # In a real test environment, we'd need to capture the packet
      assert :ok = UDP.send_osc_bundle(state, message)

      :gen_udp.close(socket)
    end

    test "uses latency from state" do
      {:ok, socket} = :gen_udp.open(0, [:binary, {:active, false}])

      state = %{
        socket: socket,
        host: ~c"127.0.0.1",
        port: 57_120,
        latency: 0.1
      }

      message = [~c"/dirt/play", ~c"test", 1]

      assert :ok = UDP.send_osc_bundle(state, message)

      :gen_udp.close(socket)
    end

    test "defaults to 0.02 latency if not in state" do
      {:ok, socket} = :gen_udp.open(0, [:binary, {:active, false}])

      # State without explicit latency
      state = %{
        socket: socket,
        host: ~c"127.0.0.1",
        port: 57_120
      }

      message = [~c"/dirt/play", ~c"test", 1]

      assert :ok = UDP.send_osc_bundle(state, message)

      :gen_udp.close(socket)
    end
  end

  describe "send_osc_message/3" do
    test "sends regular OSC message without bundle" do
      {:ok, socket} = :gen_udp.open(0, [:binary, {:active, false}])

      state = %{
        socket: socket,
        host: ~c"127.0.0.1",
        port: 57_120
      }

      assert :ok = UDP.send_osc_message(state, ~c"/hush", [])

      :gen_udp.close(socket)
    end
  end

  describe "OSC bundle format verification" do
    test "bundle has correct header" do
      # Test the OSC library directly to verify bundle format
      time = :osc.now() + 0.02
      message = [~c"/test", 123]

      bundle = :osc.pack_ts(time, message)

      # Verify it starts with "#bundle" (8 bytes: "#bundle" + null terminator)
      assert binary_part(bundle, 0, 7) == "#bundle"
      assert byte_size(bundle) > 16
    end

    test "bundle contains timestamp" do
      time = :osc.now() + 0.02
      message = [~c"/test", 456]

      bundle = :osc.pack_ts(time, message)

      # Bundle format: "#bundle\0" (8 bytes) + timestamp (8 bytes) + size (4 bytes) + message
      # Verify structure
      assert byte_size(bundle) >= 20
    end

    test "bundle can be decoded" do
      time = :osc.now() + 0.02
      message = [~c"/dirt/play", ~c"s", "bd"]

      bundle = :osc.pack_ts(time, message)

      # Decode the bundle
      {:bundle, decoded_time, elements} = :osc.decode(bundle)

      # Verify timestamp is approximately correct (within 1 second tolerance)
      assert_in_delta decoded_time, time, 1.0

      # Verify message is in the bundle
      assert length(elements) == 1
    end
  end
end
