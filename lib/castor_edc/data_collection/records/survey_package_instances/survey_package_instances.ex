defmodule CastorEDC.DataCollection.Records.SurveyPackageInstances do
  @moduledoc """
  Provides access to survey package instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  Updates the start time for a survey package instance

  [More info](https://data.castoredc.com/api#/survey/patch_study__study_id__record__record_id__surveypackageinstance__survey_package_instance_id_)
  """
  def patch(%Client{} = client, study_id, record_id, survey_package_instance_id, body) do
    patch(
      "api/study/" <>
        study_id <>
        "/record/" <> record_id <> "/surveypackageinstance/" <> survey_package_instance_id,
      client,
      body
    )
  end
end
