defmodule Mix.Tasks.CastorEdc.Spec.Fetch do
  @shortdoc "Downloads the Castor EDC API spec into priv/openapi/upstream.json"

  @default_url "https://data.castoredc.com/api/swagger?format=json"
  @moduledoc """
  Downloads the Castor EDC API spec, as published, into
  `priv/openapi/upstream.json`.

      $ mix castor_edc.spec.fetch
      $ mix castor_edc.spec.fetch --url https://us.castoredc.com/api/swagger?format=json

  The file is written with sorted keys and indentation, so a new version of
  the spec shows up as a readable diff. It's the input of
  `mix castor_edc.spec.build`, which applies our corrections to it.

  ## Options

    * `--url` - where to fetch the spec from. Defaults to
      `#{@default_url}`. A `file://`
      URL reads a local file instead.
    * `--output` - where to write it. Defaults to `priv/openapi/upstream.json`.
  """

  use Mix.Task

  alias CastorEDC.Generator.JSON

  @default_output "priv/openapi/upstream.json"

  @impl Mix.Task
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: [url: :string, output: :string])
    url = Keyword.get(opts, :url, @default_url)
    output = Keyword.get(opts, :output, @default_output)

    spec = url |> download!() |> Elixir.JSON.decode!()

    File.mkdir_p!(Path.dirname(output))
    File.write!(output, JSON.encode!(spec))

    Mix.shell().info("Wrote #{output} (#{spec["info"]["title"]} #{spec["info"]["version"]})")
  end

  defp download!("file://" <> path), do: File.read!(path)

  defp download!(url) do
    {:ok, _apps} = Application.ensure_all_started([:inets, :ssl])

    ssl = [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get(),
      customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
    ]

    request = {String.to_charlist(url), [{~c"accept", ~c"application/json"}]}

    case :httpc.request(:get, request, [ssl: ssl], body_format: :binary) do
      {:ok, {{_version, 200, _reason}, _headers, body}} ->
        body

      {:ok, {{_version, status, _reason}, _headers, _body}} ->
        Mix.raise("Fetching #{url} failed with HTTP status #{status}")

      {:error, reason} ->
        Mix.raise("Fetching #{url} failed: #{inspect(reason)}")
    end
  end
end
