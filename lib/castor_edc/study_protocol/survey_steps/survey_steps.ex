defmodule CastorEDC.StudyProtocol.SurveySteps do
  @moduledoc """
  Provides access to survey step related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all survey steps

  [More info](https://data.castoredc.com/api#/survey-step/get_study__study_id__survey__survey_id__survey_step)
  """
  def list(%Client{} = client, study_id, survey_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/survey/" <> survey_id <> "/survey-step",
      client,
      params
    )
  end

  @doc """
  Find a specific survey step

  https://data.castoredc.com/api#/survey-step/get_study__study_id__survey__survey_id__survey_step__survey_step_id_)
  """
  def find(%Client{} = client, study_id, survey_id, survey_step_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/survey/" <> survey_id <> "/survey-step/" <> survey_step_id,
      client,
      params
    )
  end
end
