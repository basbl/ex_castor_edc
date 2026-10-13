defmodule CastorEDC.TestStudy do
  @moduledoc """
  Access to the Castor EDC test study that fixtures are recorded from and
  end-to-end tests run against.

  It's configured through the environment, with nothing committed:

    * `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET`
    * `CASTOR_EDC_STUDY_ID` - the test study
    * `CASTOR_EDC_BASE_URL` - optional, `https://data.castoredc.com` by
      default; set it to use another region or a development environment

  The test study may be transient, so nothing here assumes more than its
  ID: the IDs operations need are taken from the study's own collections.
  """

  alias CastorEDC.Generator.Spec

  @variables ~w(CASTOR_EDC_CLIENT_ID CASTOR_EDC_CLIENT_SECRET CASTOR_EDC_STUDY_ID)

  # Where each path parameter's value comes from: the collection that lists
  # candidates, the path to its records, and the key of the ID. Parameters
  # that depend on another come after it.
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

  @doc """
  The environment variables that are required but not set.
  """
  @spec missing() :: [String.t()]
  def missing, do: Enum.filter(@variables, &(System.get_env(&1) in [nil, ""]))

  @doc """
  The test study's ID.
  """
  @spec id() :: String.t()
  def id, do: System.fetch_env!("CASTOR_EDC_STUDY_ID")

  @doc """
  A client for the test study's server, from the environment. Options go to
  `CastorEDC.new/1`.
  """
  @spec client(keyword()) :: Req.Request.t()
  def client(options \\ []) do
    case System.get_env("CASTOR_EDC_BASE_URL") do
      url when url in [nil, ""] -> CastorEDC.new(options)
      url -> CastorEDC.new(Keyword.put_new(options, :base_url, url))
    end
  end

  @doc """
  An ID for every path parameter the study can provide, keyed by the
  parameter's Elixir name, starting from `ids` (the study ID by default).
  """
  @spec ids(Req.Request.t(), map()) :: %{optional(String.t()) => String.t()}
  def ids(client, ids \\ %{"study_id" => id()}) do
    Enum.reduce(@sources, ids, fn {name, path, items, key}, ids ->
      case first_id(client, path, items, key, ids) do
        nil -> ids
        id -> Map.put_new(ids, name, to_string(id))
      end
    end)
  end

  @doc """
  The path of `operation` with `ids` filled in, or `:missing` when an ID is
  missing.
  """
  @spec path(Spec.Operation.t(), map()) :: {:ok, String.t()} | :missing
  def path(%Spec.Operation{} = operation, ids) do
    operation.path_params
    |> Enum.reduce(operation.path, fn param, path -> String.replace(path, "{#{param.wire}}", "{#{param.name}}") end)
    |> fill(ids)
  end

  @doc """
  The values of `operation`'s path parameters, in argument order, or
  `:missing` when an ID is missing.
  """
  @spec arguments(Spec.Operation.t(), map()) :: {:ok, [String.t()]} | :missing
  def arguments(%Spec.Operation{} = operation, ids) do
    values = Enum.map(operation.path_params, &Map.get(ids, &1.name))
    if Enum.all?(values), do: {:ok, values}, else: :missing
  end

  defp first_id(client, path, items, key, ids) do
    with {:ok, url} <- fill(path, ids),
         {:ok, %Req.Response{status: 200, body: body}} <-
           Req.get(client, url: url, headers: [accept: "application/json"]),
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
        %{^name => value} ->
          {:cont, {:ok, String.replace(path, placeholder, URI.encode(value, &URI.char_unreserved?/1))}}

        _missing ->
          {:halt, :missing}
      end
    end)
  end
end
