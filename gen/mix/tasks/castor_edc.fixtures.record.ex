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
  does: `CASTOR_EDC_CLIENT_ID`, `CASTOR_EDC_CLIENT_SECRET`,
  `CASTOR_EDC_STUDY_ID` and, optionally, `CASTOR_EDC_BASE_URL`.

  ## Options

    * `--only` - comma-separated operation IDs to record, all by default
    * `--output` - the directory to write to, `test/fixtures` by default
  """

  use Mix.Task

  alias CastorEDC.Generator
  alias CastorEDC.Generator.JSON

  # Where each path parameter's value comes from: the operation that lists
  # candidates, the path to its records, and the key of the ID. Parameters
  # that depend on another are resolved after it.
  @sources [
    {"country_id", "/api/country", "results", "id"},
    {"user_id", "/api/user", "_embedded.user", "id"},
    {"participant_id", "/api/study/{study_id}/participant", "_embedded.participants", "participant_id"},
    {"site_id", "/api/study/{study_id}/site", "_embedded.sites", "id"},
    {"field_id", "/api/study/{study_id}/field", "_embedded.fields", "id"},
    {"field_dependency_id", "/api/study/{study_id}/field-dependency", "_embedded.fieldDependencies", "id"},
    {"field_validation_id", "/api/study/{study_id}/field-validation", "_embedded.fieldValidations", "id"},
    {"option_group_id", "/api/study/{study_id}/field-optiongroup", "_embedded.fieldOptionGroups", "id"},
    {"form_id", "/api/study/{study_id}/form", "_embedded.forms", "id"},
    {"visit_id", "/api/study/{study_id}/visit", "_embedded.visits", "id"},
    {"metadata_id", "/api/study/{study_id}/metadata", "_embedded.metadatas", "id"},
    {"metadata_type_id", "/api/study/{study_id}/metadatatype", "_embedded.metadatatypes", "id"},
    {"query_id", "/api/study/{study_id}/query", "_embedded.queries", "id"},
    {"role_name", "/api/study/{study_id}/role", "_embedded.roles", "name"},
    {"repeating_data_id", "/api/study/{study_id}/repeating-data", "_embedded.repeatingData", "id"},
    {"repeating_data_form_id", "/api/study/{study_id}/repeating-data/{repeating_data_id}/repeating-data-form",
     "_embedded.repeating_data_forms", "id"},
    {"repeating_data_instance_id", "/api/study/{study_id}/repeating-data-instance", "_embedded.repeatingDataInstance",
     "id"},
    {"survey_id", "/api/study/{study_id}/survey", "_embedded.surveys", "id"},
    {"survey_form_id", "/api/study/{study_id}/survey/{survey_id}/survey-form", "_embedded.survey_forms", "id"},
    {"survey_package_id", "/api/study/{study_id}/survey-package", "_embedded.survey_packages", "id"},
    {"survey_package_instance_id", "/api/study/{study_id}/survey-package-instance", "_embedded.surveypackageinstance",
     "id"},
    {"survey_instance_id", "/api/study/{study_id}/survey-package-instance/{survey_package_instance_id}",
     "_embedded.survey_instances", "id"},
    {"export_id", "/api/study/{study_id}/export", "_embedded.items", "id"}
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: [only: :string, output: :string])
    Mix.Task.run("app.start")

    client = client!()
    output = Keyword.get(opts, :output, "test/fixtures")
    only = opts[:only] && String.split(opts[:only], ",")

    ids = discover_ids(client, %{"study_id" => System.fetch_env!("CASTOR_EDC_STUDY_ID")})

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
    for name <- ~w(CASTOR_EDC_CLIENT_ID CASTOR_EDC_CLIENT_SECRET CASTOR_EDC_STUDY_ID),
        System.get_env(name) in [nil, ""] do
      Mix.raise("#{name} isn't set; see `mix help castor_edc.fixtures.record`")
    end

    case System.get_env("CASTOR_EDC_BASE_URL") do
      url when url in [nil, ""] -> CastorEDC.new()
      url -> CastorEDC.new(base_url: url)
    end
  end

  defp discover_ids(client, ids) do
    Enum.reduce(@sources, ids, fn {name, path, items, key}, ids ->
      case first_id(client, path, items, key, ids) do
        nil -> ids
        id -> Map.put(ids, name, to_string(id))
      end
    end)
  end

  defp first_id(client, path, items, key, ids) do
    with {:ok, url} <- fill(path, ids),
         {:ok, %Req.Response{status: 200, body: body}} <- Req.get(client, url: url, headers: [accept: "application/json"]),
         [record | _rest] <- records(body, items) do
      record[key]
    else
      _none -> nil
    end
  end

  defp records(body, path) do
    path |> String.split(".") |> Enum.reduce(body, fn key, data -> is_map(data) && data[key] end) |> List.wrap()
  end

  defp fill(path, ids) do
    ~r/\{([^}]+)\}/
    |> Regex.scan(path)
    |> Enum.reduce_while({:ok, path}, fn [placeholder, name], {:ok, path} ->
      case ids do
        %{^name => value} -> {:cont, {:ok, String.replace(path, placeholder, URI.encode(value, &URI.char_unreserved?/1))}}
        _missing -> {:halt, :missing}
      end
    end)
  end

  defp record(client, operation, ids, output) do
    wires = Map.new(operation.path_params, &{&1.name, &1.wire})

    template =
      Enum.reduce(wires, operation.path, fn {name, wire}, path -> String.replace(path, "{#{wire}}", "{#{name}}") end)

    with {:ok, url} <- fill(template, ids),
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
