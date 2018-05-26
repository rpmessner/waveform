defmodule Waveform.Synth do
  use GenServer

  @me __MODULE__

  defmodule State do
    defstruct(
      a: nil
    )
  end

  def start_link(opts \\ []) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    Waveform.OSC.load_synthdefs
    Waveform.OSC.request_notifications

    {:ok, state}
  end

end
