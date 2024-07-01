defmodule ChurchNumerals.MixProject do
  use Mix.Project

  def project do
    [
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        flags: [
          :unmatched_returns,
          :error_handling,
          :no_opaque
        ],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ],
      app: :church_numerals,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:propcheck, "~> 1.4.1", only: [:dev, :test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
