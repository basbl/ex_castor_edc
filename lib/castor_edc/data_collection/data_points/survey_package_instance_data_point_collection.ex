defmodule CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection do
  @moduledoc """
  Provides access to survey package instance data point collection for all participants
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for a survey package instance

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_survey_package_instance__survey_package_instance_id_)
  """
  def list(%Client{} = client, study_id, survey_package_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/data-points/survey-package-instance/" <> survey_package_instance_id,
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a survey package instance

  [More info](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_survey_package_instance__survey_package_instance_id_)
  """
  def create(%Client{} = client, study_id, participant_id, survey_package_instance_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/participant/" <>
        participant_id <>
        "/data-points/survey-package-instance/" <> survey_package_instance_id,
      client,
      body
    )
  end
end
