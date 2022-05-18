defmodule CastorEDC.StudyProtocol.FieldDependencies do
  @moduledoc """
  Provides access to field dependency related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all field dependencies

  [More info](https://data.castoredc.com/api#/field-dependency/get_study__study_id__field_dependency)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-dependency",
      client,
      params
    )
  end

  @doc """
  Find a specific field dependency

  [More info](https://data.castoredc.com/api#/field-dependency/get_study__study_id__field_dependency__fieldDependency_id_)
  """
  def find(%Client{} = client, study_id, field_dependency_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-dependency/" <> field_dependency_id,
      client,
      params
    )
  end
end
