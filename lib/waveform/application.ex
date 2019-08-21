defmodule Waveform.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Waveform.AudioBus, nil},
      {Waveform.Beat, nil},
      {Waveform.Lang, nil},
      # {Waveform.Midi, nil},
      {Waveform.OSC, nil},
      {Waveform.OSC.Node.ID, 3},
      {Waveform.OSC.Node, nil},
      {Waveform.OSC.Group, nil},
      {Waveform.ServerInfo, nil},
      {Waveform.Synth.Manager, nil},
      {Waveform.Synth.Def.Submodule, nil}
    ]

    opts = [strategy: :one_for_one, name: Waveform.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
