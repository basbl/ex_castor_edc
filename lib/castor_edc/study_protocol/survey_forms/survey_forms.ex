defmodule CastorEDC.StudyProtocol.SurveyForms do
  @moduledoc """
  Provides access to survey form related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all survey forms

  [More info](https://data.castoredc.com/api#/survey-form/get_study__study_id__survey__survey_id__survey_form)
  """
  def list(%Client{} = client, study_id, survey_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/survey/" <> survey_id <> "/survey-form",
      client,
      params
    )
  end

  @doc """
  Find a specific survey form

  https://data.castoredc.com/api#/survey-form/get_study__study_id__survey__survey_id__survey_form__survey_form_id_)
  """
  def find(%Client{} = client, study_id, survey_id, survey_form_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/survey/" <> survey_id <> "/survey-form/" <> survey_form_id,
      client,
      params
    )
  end
end
