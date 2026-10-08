defmodule CastorEDC.MixProject do
  use Mix.Project

  @version "0.4.1"
  @source_url "https://github.com/basbl/ex_castor_edc/"
  @homepage_url "https://www.castoredc.com/"

  def project do
    [
      name: "ExCastorEDC",
      app: :ex_castor_edc,
      version: @version,
      elixir: "~> 1.20",
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_local_path: "priv/plts",
        plt_core_path: "priv/plts",
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:eex, :ex_unit, :mix, :yaml_elixir, :inets, :ssl, :public_key]
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def cli do
    [
      preferred_envs: [
        precommit: :test,
        quality: :dev,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.post": :test
      ]
    ]
  end

  defp docs do
    [
      main: "CastorEDC",
      source_ref: @version,
      source_url: @source_url,
      homepage_url: @homepage_url,
      groups_for_modules: [
        Common: ~r"CastorEDC.Common",
        "Data Collection": ~r"CastorEDC.DataCollection",
        "Study Protocol": ~r"CastorEDC.StudyProtocol"
      ],
      extras: ["README.md", "notebook/getting_started.livemd", "guides/migrating-to-1.0.md", "CHANGELOG.md"],
      # The CHANGELOG names functions of earlier releases.
      skip_code_autolink_to: ["CastorEDC.authenticate/1", "CastorEDC.Client.new/2"]
    ]
  end

  # gen/ holds the client generator and its Mix tasks: development tooling
  # that is compiled in :dev and :test only and isn't part of the package.
  defp elixirc_paths(:dev), do: ["lib", "gen"]
  defp elixirc_paths(:test), do: ["lib", "gen", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp package do
    [
      files: ~w(lib priv/openapi/castor_edc.json .formatter.exs mix.exs README.md CHANGELOG.md LICENSE.md),
      description: "Elixir wrapper for the Castor EDC API",
      maintainers: ["Bas Bloembergen"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Homepage" => @homepage_url
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {CastorEDC.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 1.0"},
      {:req, "~> 0.7.5"},
      {:telemetry, "~> 1.4"},
      {:tz, "~> 0.28"},
      {:excoveralls, "~> 0.18.5", only: :test},
      {:styler, "~> 1.12", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.8", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1.5", only: [:dev, :test], runtime: false},
      {:yaml_elixir, "~> 2.12", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "credo --strict", "coveralls"],
      quality: [
        # hex.audit has to run first: once another task has loaded the
        # project's code paths, Mix no longer finds tasks from the Hex archive
        "hex.audit",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "deps.audit",
        "castor_edc.spec.build --check",
        "castor_edc.gen.client --check",
        "docs --warnings-as-errors"
      ]
    ]
  end
end
