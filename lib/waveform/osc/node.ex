defmodule Waveform.OSC.Node do
  alias Waveform.OSC.Node.ID, as: ID

  alias __MODULE__

  defstruct(
    type: nil,
    id: nil
  )

  def next_node do
    %Node{type: :synth, id: ID.next()}
  end
end
