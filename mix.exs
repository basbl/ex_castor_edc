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
      elixir: "~> 1.13",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.post": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
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
      extras: ["notebook/getting_started.livemd"]
    ]
  end

  defp package do
    [
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, ">= 1.0.0"},
      {:castore, "~> 1.0"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.13"},
      {:exvcr, "~> 0.11", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
