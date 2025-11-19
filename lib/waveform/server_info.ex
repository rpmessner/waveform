defmodule Waveform.ServerInfo do
  @moduledoc """
  Tracks SuperCollider server capabilities and configuration.

  This module stores information about the running SuperCollider server,
  including sample rate, number of busses, buffers, and other server parameters.

  The information is populated automatically when the server boots and responds
  to a `/status` request with a `/status.reply` message.

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
  use GenServer

  @me __MODULE__

  defmodule State do
    @moduledoc false
    defstruct(
      sample_rate: nil,
      num_output_busses: nil,
      num_input_busses: nil,
      num_audio_busses: nil,
      num_control_busses: nil,
      num_buffers: nil
    )
  end

  def state do
    GenServer.call(@me, {:state})
  end

  def set_state(response) do
    GenServer.call(@me, {:set_state, response})
  end

  def start_link(_state) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_state, status_reply}, _from, state) do
    # /status.reply format: [unused, ugens, synths, groups, synthdefs, avg_cpu, peak_cpu, nominal_sr, actual_sr]
    # We primarily care about sample_rate for now
    # Note: We'll need to get bus/buffer counts from server boot options or assume defaults
    case status_reply do
      [_, _, _, _, _, _, _, _nominal_sr, actual_sr] ->
        new_state = %State{
          state
          | sample_rate: actual_sr,
            # SuperCollider defaults - these could be made configurable
            num_output_busses: 8,
            num_input_busses: 8,
            num_audio_busses: 1024,
            num_control_busses: 16_384,
            num_buffers: 1024
        }

        {:reply, new_state, new_state}

      _ ->
        require Logger
        Logger.warning("Unexpected /status.reply format: #{inspect(status_reply)}")
        {:reply, state, state}
    end
  end
end
