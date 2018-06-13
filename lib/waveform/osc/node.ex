defmodule Waveform.OSC.Node do
  alias Waveform.OSC.Node.ID, as: ID

  alias __MODULE__

  defstruct(
    type: nil,
    id: nil,
    out_bus: nil,
    in_bus: nil
  )

  def next_fx_node do
    %Node{type: :fx, id: ID.next()}
  end

  def next_synth_node do
    %Node{type: :synth, id: ID.next()}
  end
end
