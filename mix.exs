defmodule Waveform.MixProject do
  use Mix.Project

  def project do
    [
      app: :waveform,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # applications: [:portmidi],
      extra_applications: [:logger],
      mod: {Waveform.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exexec, "~> 0.2"},
      {:recase, "~> 0.2"},
      {:mock, "~> 0.3.2", only: :test},
      {:portmidi, "~> 5.1.2"}
    ]
  end
end
