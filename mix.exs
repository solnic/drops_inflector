defmodule Drops.Inflector.MixProject do
  use Mix.Project

  @source_url "https://github.com/solnic/drops_inflector"
  @version "0.1.0"
  @license "LGPL-3.0-or-later"

  def project do
    [
      app: :drops_inflector,
      version: @version,
      elixir: "~> 1.14",
      elixirc_options: [warnings_as_errors: false],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      licenses: [@license],
      description: ~S"""
      Inflection library for Elixir.
      """,
      links: %{"GitHub" => @source_url},
      package: package(),
      docs: docs(),
      source_url: @source_url,
      consolidate_protocols: Mix.env() == :prod,
      elixir_paths: elixir_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases()
    ]
  end

  def elixir_paths(_) do
    ["lib"]
  end

  def cli do
    [
      preferred_envs: [
        "test.coverage": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    []
  end

  defp package() do
    [
      name: "drops_inflector",
      files: ~w(lib/drops .formatter.exs mix.exs README* LICENSE CHANGELOG.md),
      licenses: [@license],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      authors: ["Peter Solnica"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:doctor, "~> 0.21.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # Mix aliases for common tasks
  defp aliases do
    [
      "test.coverage": ["coveralls.json"]
    ]
  end
end
