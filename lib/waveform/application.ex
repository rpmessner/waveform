defmodule Waveform.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Waveform.Beat, nil},
      {Waveform.Lang, nil},
      {Waveform.OSC, nil},
      {Waveform.OSC.Node.ID, 1},
      {Waveform.OSC.Node, nil},
      {Waveform.OSC.Group, nil},
      {Waveform.Synth.Manager, nil},
      {Waveform.Synth.FX, nil}
    ]

    opts = [strategy: :one_for_one, name: Waveform.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
