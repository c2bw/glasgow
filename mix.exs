defmodule Glasgow.MixProject do
  use Mix.Project

  @version "0.1.2"
  @url "https://github.com/c2bw/glasgow"

  def project do
    [
      app: :glasgow,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: "Elixir Logger handler for Grafana Loki",
      test_coverage: [ignore_modules: [~r/Logproto\./, ~r/Stats\./, Google.Protobuf.Timestamp]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Glasgow.Application, []}
    ]
  end

  defp deps do
    [
      {:mimic, "~> 1.7", only: :test},
      {:ex_doc, "~> 0.37.3", only: :dev, runtime: false},
      {:snappyrex, "~> 0.1"},
      {:protobuf, "~> 0.14.1"},
      {:req, "~> 0.5.0"}
    ]
  end

  defp package do
    [
      name: "glasgow",
      source_url: @url,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "glasgow",
      canonical: "http://hexdocs.pm/glasgow",
      source_url: @url,
      extras: ["README.md", "LICENSE"]
    ]
  end
end
