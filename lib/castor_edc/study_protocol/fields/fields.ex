defmodule CastorEDC.StudyProtocol.Fields do
  @moduledoc """
  Provides access to field related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all fields

  [More info](https://data.castoredc.com/api#/field/get_study__study_id__field)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field",
      client,
      params
    )
  end

  @doc """
  Find a specific field

  [More info](https://data.castoredc.com/api#/field/get_study__study_id__field__field_id_)
  """
  def find(%Client{} = client, study_id, field_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field/" <> field_id,
      client,
      params
    )
  end
end
