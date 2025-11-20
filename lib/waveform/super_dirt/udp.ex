defmodule Waveform.SuperDirt.UDP do
  @moduledoc """
  Production SuperDirt transport implementation using UDP.

  This module sends OSC bundles to SuperDirt via UDP. Messages are wrapped
  in OSC bundles with timestamps for accurate scheduling.
  """

  @behaviour Waveform.SuperDirt.Transport

  @impl true
  def send_osc_bundle(state, message) do
    # Get current time and add small latency for scheduling stability
    # Latency in seconds - gives SuperDirt time to process the event
    latency = Map.get(state, :latency, 0.02)
    time = :osc.now() + latency

    # Create OSC bundle with timestamp
    encoded = :osc.pack_ts(time, message)
    :ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
  end

  @impl true
  def send_osc_message(state, address, args) do
    # Encode and send raw OSC message
    encoded = :osc.encode([address | args])
    :ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
  end
end
