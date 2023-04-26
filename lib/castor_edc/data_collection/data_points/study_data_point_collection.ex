defmodule CastorEDC.DataCollection.DataPoints.StudyDataPointCollection do
  @moduledoc """
  Provides access to study instance data point collection for all participants
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for the study

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_study)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/data-points/study",
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a study

  [More info](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_study)
  """
  def create(%Client{} = client, study_id, participant_id, body) do
    post(
      "api/study/" <> study_id <> "/participant/" <> participant_id <> "/data-points/study",
      client,
      body
    )
  end
end
