defmodule CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection do
  @moduledoc """
  Provides access to survey instance data point collection for all participants
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for all surveys

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/data-points/survey-instance",
      client,
      params
    )
  end

  @doc """
  Find all collected data points for a specific survey instance

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance__survey_instance_id_
  """
  def find(%Client{} = client, study_id, survey_instance_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/data-points/survey-instance/" <> survey_instance_id,
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a survey instance

  [More info](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_survey_instance__survey_instance_id_)
  """
  def create(%Client{} = client, study_id, participant_id, survey_instance_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/participant/" <> participant_id <> "/data-points/survey-instance/" <> survey_instance_id,
      client,
      body
    )
  end
end
