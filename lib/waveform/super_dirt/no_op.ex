defmodule Waveform.SuperDirt.NoOp do
  @moduledoc """
  No-op SuperDirt transport for testing.

  This implementation accepts OSC messages but doesn't send them anywhere.
  Used in test mode to avoid requiring a running SuperDirt instance.
  """

  @behaviour Waveform.SuperDirt.Transport

  @impl true
  def send_osc_bundle(_state, _message), do: :ok

  @impl true
  def send_osc_message(_state, _address, _args), do: :ok
end
