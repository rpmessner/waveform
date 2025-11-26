defmodule Waveform.Application do
  @moduledoc """
  Main application supervisor for Waveform.

  Starts the essential processes for OSC communication with SuperCollider:
  - Lang: Manages the sclang process
  - OSC: Handles OSC message transport
  - SuperDirt: Handles SuperDirt pattern-based audio
  - PatternScheduler: High-precision pattern scheduling for continuous playback
  - Node: Node ID allocation and tracking
  - Group: Group management
  - MIDI.Port: MIDI port management and connection caching
  - MIDI.Input: MIDI input handling and event dispatch
  """
  use Application

  def start(_type, _args) do
    children = [
      {Waveform.Lang, nil},
      {Waveform.OSC, nil},
      {Waveform.SuperDirt, []},
      {Waveform.PatternScheduler, []},
      # Start node IDs at 100 to leave room for system nodes
      {Waveform.OSC.Node.ID, initial_id: 100},
      {Waveform.OSC.Node, []},
      {Waveform.OSC.Group, []},
      # MIDI port management, note scheduling, input handling, and clock sync
      {Waveform.MIDI.Port, []},
      {Waveform.MIDI.Scheduler, []},
      {Waveform.MIDI.Input, []},
      {Waveform.MIDI.Clock, []}
    ]

    opts = [strategy: :one_for_one, name: Waveform.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
