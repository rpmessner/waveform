defmodule Waveform.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Waveform.AudioBus, nil},
      {Waveform.Beat, nil},
      {Waveform.Lang, nil},
      {Waveform.Midi, nil},
      {Waveform.OSC, nil},
      {Waveform.OSC.Node.ID, 3},
      {Waveform.OSC.Group, nil},
      {Waveform.ServerInfo, nil},
      {Waveform.Synth.Manager, nil},
      {Waveform.Synth.Def.Submodule, nil},

      Waveform.Repo,
      WaveformWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: Waveform.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WaveformWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
