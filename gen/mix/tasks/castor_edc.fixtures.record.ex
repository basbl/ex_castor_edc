defmodule Mix.Tasks.CastorEdc.Fixtures.Record do
  @shortdoc "Records test fixtures from a Castor EDC test study"

  @moduledoc """
  Records the responses of the API's read operations as test fixtures.

      $ mix castor_edc.fixtures.record
      $ mix castor_edc.fixtures.record --only get_site,list_sites

  For every GET operation of `priv/openapi/castor_edc.json`, it sends the
  request to a test study and writes the response body to
  `test/fixtures/<operationId>.json`, with its status and request in
  `<operationId>.meta.json` beside it. Unit tests read these files; they
  never talk to the API.

  It only reads, so it never changes the study. The IDs operations need
  (a participant, a field, a survey package instance, …) are taken from
  the study's own collections; an operation whose IDs the study can't
  provide is skipped and reported.

  E-mail addresses become `user@example.org` and personal names
  `Test User`, so fixtures hold no personal data even when the study does,
  and links name `https://data.castoredc.com` whatever server the study is
  on.

  It reads its configuration from the environment, as the end-to-end suite
  does; see `CastorEDC.TestStudy`.

  ## Options

    * `--only` - comma-separated operation IDs to record, all by default
    * `--output` - the directory to write to, `test/fixtures` by default
  """

  use Mix.Task

  alias CastorEDC.Generator
  alias CastorEDC.Generator.JSON
  alias CastorEDC.TestStudy

  @impl Mix.Task
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: [only: :string, output: :string])
    Mix.Task.run("app.start")

    client = client!()
    output = Keyword.get(opts, :output, "test/fixtures")
    only = opts[:only] && String.split(opts[:only], ",")

    ids = TestStudy.ids(client)

    operations =
      for group <- Generator.load!("priv/openapi/castor_edc.json").groups,
          operation <- group.operations,
          operation.method == :get,
          only == nil or operation.name in only,
          do: operation

    File.mkdir_p!(output)

    {recorded, skipped} =
      Enum.split_with(operations, fn operation -> record(client, operation, ids, output) end)

    Mix.shell().info("Recorded #{length(recorded)} fixtures in #{output}")

    if skipped != [] do
      Mix.shell().info("Skipped, for lack of IDs or a successful response: " <> Enum.map_join(skipped, ", ", & &1.name))
    end
  end

  defp client! do
    case TestStudy.missing() do
      [] -> TestStudy.client()
      [name | _rest] -> Mix.raise("#{name} isn't set; see `mix help castor_edc.fixtures.record`")
    end
  end

  defp record(client, operation, ids, output) do
    with {:ok, url} <- TestStudy.path(operation, ids),
         accept = operation.accept || "application/hal+json",
         {:ok, %Req.Response{status: status, body: body}} when status in 200..299 and is_map(body) <-
           Req.get(client, url: url, headers: [accept: accept], decode_body: true) do
      body = body |> scrub() |> public_server(client.options.base_url)
      File.write!(Path.join(output, operation.name <> ".json"), JSON.encode!(body))

      meta = %{"operation" => operation.name, "method" => "GET", "path" => url, "query" => nil, "status" => status}
      File.write!(Path.join(output, operation.name <> ".meta.json"), JSON.encode!(meta))
      true
    else
      _not_recorded -> false
    end
  end

  @personal ~w(full_name name_first name_last name_middle first_name last_name)

  @doc false
  def scrub(%{} = map) do
    Map.new(map, fn
      {key, value} when key in @personal and is_binary(value) and value != "" -> {key, "Test User"}
      {key, value} -> {key, scrub(value)}
    end)
  end

  def scrub(list) when is_list(list), do: Enum.map(list, &scrub/1)

  def scrub(text) when is_binary(text) do
    String.replace(text, ~r/[A-Za-z0-9._%+-]+@(?!example\.(org|com)\b)[A-Za-z0-9.-]+\.[A-Za-z]{2,}/, "user@example.org")
  end

  def scrub(other), do: other

  @doc false
  # Links name the server the fixtures were recorded on, which may be a
  # development environment; fixtures name data.castoredc.com instead.
  def public_server(value, server) when is_map(value),
    do: Map.new(value, fn {key, value} -> {key, public_server(value, server)} end)

  def public_server(value, server) when is_list(value), do: Enum.map(value, &public_server(&1, server))

  def public_server(value, server) when is_binary(value) do
    String.replace(value, String.trim_trailing(server, "/"), "https://data.castoredc.com")
  end

  def public_server(value, _server), do: value
end
