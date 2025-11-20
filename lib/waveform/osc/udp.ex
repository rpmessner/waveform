defmodule Waveform.OSC.UDP do
  @moduledoc """
  Production OSC transport implementation using UDP.

  This module sends actual OSC messages to SuperCollider via UDP.
  """

  @behaviour Waveform.OSC.Transport

  @impl true
  def send_osc_message(state, address, args) do
    # Encode and send the OSC message via UDP
    :ok = :gen_udp.send(state.socket, state.host, state.host_port, :osc.encode([address | args]))
  end
end
