use Mix.Config

config :waveform, :viewport, %{
  name: :main_viewport,
  size: {700, 600},
  default_scene: {Waveform.Scenes.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizable: false, title: "waveform"]
    }
  ]
}

