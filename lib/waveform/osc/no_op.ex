defmodule Waveform.OSC.NoOp do
  @moduledoc """
  No-op OSC transport implementation for testing.

  This module accepts OSC messages but doesn't actually send them anywhere.
  Used in test environment to avoid requiring a running SuperCollider instance.
  """

  @behaviour Waveform.OSC.Transport

  @impl true
  def send_osc_message(_state, _address, _args) do
    # Accept the message but don't send it anywhere
    :ok
  end
end
