defmodule CastorEDC.DataCollection.Participants.SurveyPackageInstances do
  @moduledoc """
  Provides access to survey package instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  Updates the start time for a survey package instance

  [More info](https://data.castoredc.com/api#/survey/patch_study__study_id__survey_package_instance__survey_package_instance_id_)
  """
  def patch(%Client{} = client, study_id, participant_id, survey_package_instance_id, body) do
    patch(
      "api/study/" <>
        study_id <>
        "/participant/" <>
        participant_id <> "/survey-package-instance/" <> survey_package_instance_id,
      client,
      body
    )
  end
end
