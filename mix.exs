defmodule Waveform.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/rpmessner/waveform"

  def project do
    [
      app: :waveform,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Waveform",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Waveform.Application, []}
    ]
  end

  defp deps do
    [
      {:exexec, "~> 0.2"},
      {:recase, "~> 0.2"},

      # Optional dependencies
      {:harmony, git: "https://github.com/rpmessner/harmony", optional: true},

      # Dev/test dependencies
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3.2", only: :test}
    ]
  end

  defp description do
    """
    A simple OSC transport layer for communicating with SuperCollider from Elixir.
    Provides low-level OSC messaging and node/group management for live coding and audio synthesis.
    Requires SuperCollider to be installed on your system.
    """
  end

  defp package do
    [
      name: "waveform",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      maintainers: ["Ryan Messner"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
