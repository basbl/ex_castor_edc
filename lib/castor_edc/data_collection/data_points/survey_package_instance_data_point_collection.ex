defmodule CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection do
  @moduledoc """
  Provides access to survey package instance data point collection for all records
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for a survey package instance

  [More info](https://data.castoredc.com/api#/data-point-collection/get_study__study_id__record__record_id__data_point_collection_survey_package_instance__survey_package_instance_id_)
  """
  def list(%Client{} = client, study_id, survey_package_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/data-point-collection/survey-package-instance/" <> survey_package_instance_id,
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a survey package instance

  [More info](https://data.castoredc.com/api#/data-point-collection/post_study__study_id__record__record_id__data_point_collection_survey_package_instance__survey_package_instance_id_)
  """
  def create(%Client{} = client, study_id, record_id, survey_package_instance_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/record/" <>
        record_id <>
        "/data-point-collection/survey-package-instance/" <> survey_package_instance_id,
      client,
      body
    )
  end
end
