defmodule Waveform.Application do
  @moduledoc """
  Main application supervisor for Waveform.

  Starts the essential processes for OSC communication with SuperCollider:
  - Lang: Manages the sclang process
  - OSC: Handles OSC message transport
  - Node: Node ID allocation and tracking
  - Group: Group management
  """
  use Application

  def start(_type, _args) do
    children = [
      {Waveform.Lang, nil},
      {Waveform.OSC, nil},
      # Start node IDs at 100 to leave room for system nodes
      {Waveform.OSC.Node.ID, 100},
      {Waveform.OSC.Node, nil},
      {Waveform.OSC.Group, nil}
    ]

    opts = [strategy: :one_for_one, name: Waveform.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
