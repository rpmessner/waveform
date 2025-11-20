defmodule Waveform.ServerInfo do
  @moduledoc """
  Minimal server information storage.

  Stores only sample rate from SuperCollider's /status.reply message.
  Uses :persistent_term for fast, concurrent reads with no process overhead.
  """

  @sample_rate_key {__MODULE__, :sample_rate}

  @doc """
  Process a /status.reply message and store the sample rate.

  ## Status Reply Format
  The `/status.reply` message contains:
  1. unused (int)
  2. num_ugens (int)
  3. num_synths (int)
  4. num_groups (int)
  5. num_loaded_synthdefs (int)
  6. avg_cpu (float)
  7. peak_cpu (float)
  8. nominal_sample_rate (double)
  9. actual_sample_rate (double)
  """
  def set_from_status_reply(response) do
    case response do
      [_, _, _, _, _, _, _, _nominal_sr, actual_sr] ->
        :persistent_term.put(@sample_rate_key, actual_sr)
        :ok

      _ ->
        require Logger
        Logger.warning("Unexpected /status.reply format: #{inspect(response)}")
        :error
    end
  end

  @doc """
  Get the current sample rate.

  Returns `nil` if not yet set by the server.
  """
  def sample_rate do
    :persistent_term.get(@sample_rate_key, nil)
  end
end
