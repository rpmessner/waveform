defmodule Waveform.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/rpmessner/waveform"

  def project do
    [
      app: :waveform,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Waveform",
      source_url: @source_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    case Mix.env() do
      :test ->
        [extra_applications: [:logger]]

      _ ->
        [
          extra_applications: [:logger, :erlexec],
          mod: {Waveform.Application, []}
        ]
    end
  end

  defp deps do
    [
      {:erlexec, "~> 2.0"},
      {:recase, "~> 0.2"},

      # Dev/test dependencies
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false}
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
