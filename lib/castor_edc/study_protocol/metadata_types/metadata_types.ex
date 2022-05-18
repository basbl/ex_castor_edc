defmodule CastorEDC.StudyProtocol.MetadataTypes do
  @moduledoc """
  Provides access to metadata type related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all metadata types

  [More info](https://data.castoredc.com/api#/metadatatype/get_study__study_id__metadatatype)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/metadatatype",
      client,
      params
    )
  end

  @doc """
  Find a specific metadata type

  [More info](https://data.castoredc.com/api#/metadatatype/get_study__study_id__metadatatype__metadatatype_id_)
  """
  def find(%Client{} = client, study_id, metadata_type_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/metadatatype/" <> metadata_type_id,
      client,
      params
    )
  end
end
