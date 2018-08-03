defmodule Waveform.MixProject do
  use Mix.Project

  def project do
    [
      app: :waveform,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:porcelain, :portmidi],
      extra_applications: [:logger],
      mod: {Waveform.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:porcelain, "~> 2.0"},
      {:mock, "~> 0.3.0", only: :test},
      {:portmidi, "~> 5.1.1"}
    ]
  end
end
