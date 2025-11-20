defmodule Waveform.SuperDirt.Transport do
  @moduledoc """
  Behaviour for SuperDirt message transport.

  This behaviour defines the interface for sending OSC messages to SuperDirt.
  Different implementations can be used for production (UDP) and testing (NoOp).

  ## Implementations

  - `Waveform.SuperDirt.UDP` - Production implementation that sends OSC bundles via UDP
  - `Waveform.SuperDirt.NoOp` - Test implementation that accepts messages but doesn't send them
  """

  @doc """
  Send an OSC bundle to SuperDirt.

  SuperDirt expects messages wrapped in OSC bundles with timestamps for
  accurate scheduling.

  ## Parameters
  - `state` - The SuperDirt GenServer state (contains socket and host info)
  - `message` - OSC message as a list [address | args]

  ## Returns
  `:ok` on success
  """
  @callback send_osc_bundle(state :: map(), message :: list()) :: :ok

  @doc """
  Send a raw OSC message (for control commands that don't need bundles).

  ## Parameters
  - `state` - The SuperDirt GenServer state
  - `address` - OSC address as a charlist
  - `args` - List of OSC arguments

  ## Returns
  `:ok` on success
  """
  @callback send_osc_message(state :: map(), address :: charlist(), args :: list()) :: :ok
end
