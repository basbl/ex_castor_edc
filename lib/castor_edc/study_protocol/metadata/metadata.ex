defmodule CastorEDC.StudyProtocol.Metadata do
  @moduledoc """
  Provides access to metadata related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all metadata

  [More info](https://data.castoredc.com/api#/metadata/get_study__study_id__metadata)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/metadata",
      client,
      params
    )
  end

  @doc """
  Find specific metadata

  [More info](https://data.castoredc.com/api#/metadata/get_study__study_id__metadata__metadata_id_)
  """
  def find(%Client{} = client, study_id, metadata_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/metadata/" <> metadata_id,
      client,
      params
    )
  end
end
