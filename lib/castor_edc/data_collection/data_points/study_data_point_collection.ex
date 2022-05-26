defmodule CastorEDC.DataCollection.DataPoints.StudyDataPointCollection do
  @moduledoc """
  Provides access to study instance data point collection for all records
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for the study

  [More info](https://data.castoredc.com/api#/data-point-collection/get_study__study_id__data_point_collection_study)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/data-point-collection/study",
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a study

  [More info](https://data.castoredc.com/api#/data-point-collection/post_study__study_id__record__record_id__data_point_collection_study)
  """
  def create(%Client{} = client, study_id, record_id, body) do
    post(
      "api/study/" <> study_id <> "/record/" <> record_id <> "/data-point-collection/study",
      client,
      body
    )
  end
end
