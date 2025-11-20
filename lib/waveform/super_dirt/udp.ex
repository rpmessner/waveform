defmodule Waveform.SuperDirt.UDP do
  @moduledoc """
  Production SuperDirt transport implementation using UDP.

  This module sends OSC bundles to SuperDirt via UDP. Messages are wrapped
  in OSC bundles with timestamps for accurate scheduling.
  """

  @behaviour Waveform.SuperDirt.Transport

  @impl true
  def send_osc_bundle(state, message) do
    # For now, send as a regular OSC message
    # TODO: Implement proper OSC bundle support with timestamps
    encoded = :osc.encode(message)
    :ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
  end

  @impl true
  def send_osc_message(state, address, args) do
    # Encode and send raw OSC message
    encoded = :osc.encode([address | args])
    :ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
  end
end
