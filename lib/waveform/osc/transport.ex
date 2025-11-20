defmodule Waveform.OSC.Transport do
  @moduledoc """
  Behaviour for OSC message transport.

  This behaviour defines the interface for sending OSC messages to SuperCollider.
  Different implementations can be used for production (UDP) and testing (NoOp).

  ## Implementations

  - `Waveform.OSC.UDP` - Production implementation that sends actual OSC messages via UDP
  - `Waveform.OSC.NoOp` - Test implementation that accepts messages but doesn't send them
  """

  @doc """
  Send an OSC message.

  ## Parameters
  - `state` - The OSC GenServer state (contains socket and host info)
  - `address` - OSC address as a charlist (e.g., '/s_new', '/g_new')
  - `args` - List of OSC arguments

  ## Returns
  `:ok` on success
  """
  @callback send_osc_message(state :: map(), address :: charlist(), args :: list()) :: :ok
end
