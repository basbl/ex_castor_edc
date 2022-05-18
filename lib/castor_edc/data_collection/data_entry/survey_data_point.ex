defmodule CastorEDC.DataCollection.DataEntry.SurveyDataPoint do
  @moduledoc """
  Provides access to survey data point related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected survey data points for a record

  [More info](https://data.castoredc.com/api#/survey-data-entry/get_study__study_id__record__record_id__data_point_survey__survey_instance_id_)
  """
  def list(%Client{} = client, study_id, record_id, survey_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/record/" <> record_id <> "/data-point/survey/" <> survey_instance_id,
      client,
      params
    )
  end

  @doc """
  Find a data point for a record in a specific survey instance

  [More info](https://data.castoredc.com/api#/survey-data-entry/get_study__study_id__record__record_id__data_point_survey__survey_instance_id___field_id_)
  """
  def find(%Client{} = client, study_id, record_id, survey_instance_id, field_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/record/" <> record_id <> "/data-point/survey/" <> survey_instance_id <> "/" <> field_id,
      client,
      params
    )
  end

  @doc """
  Create a new data point in a specific survey instance for a record

  [More info](https://data.castoredc.com/api#/survey-data-entry/get_study__study_id__record__record_id__data_point_survey__survey_instance_id___field_id_)
  """
  def create(%Client{} = client, study_id, record_id, survey_instance_id, field_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/record/" <> record_id <> "/data-point/survey/" <> survey_instance_id <> "/" <> field_id,
      client,
      body
    )
  end
end
