defmodule Waveform.ServerInfo do
  @moduledoc """
  Tracks SuperCollider server capabilities and configuration.

  This module stores information about the running SuperCollider server,
  including sample rate, number of busses, buffers, and other server parameters.

  The information is populated automatically when the server boots and reports
  its status.
  """
  use GenServer

  @me __MODULE__

  defmodule State do
    defstruct(
      sample_rate: nil,
      sample_dur: nil,
      radians_per_sample: nil,
      control_rate: nil,
      control_dur: nil,
      subsample_offset: nil,
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

  def handle_call({:set_state, state}, _from, _state) do
    [
      sample_rate,
      sample_dur,
      radians_per_sample,
      control_rate,
      control_dur,
      subsample_offset,
      num_output_busses,
      num_input_busses,
      num_audio_busses,
      num_control_busses,
      num_buffers,
      _
    ] = state

    new_state = %State{
      sample_rate: sample_rate,
      sample_dur: sample_dur,
      radians_per_sample: radians_per_sample,
      control_rate: control_rate,
      control_dur: control_dur,
      subsample_offset: subsample_offset,
      num_output_busses: num_output_busses,
      num_input_busses: num_input_busses,
      num_audio_busses: num_audio_busses,
      num_control_busses: num_control_busses,
      num_buffers: num_buffers
    }

    {:reply, new_state, new_state}
  end
end
