defmodule CastorEDC.StudyProtocol.SurveyPackages do
  @moduledoc """
  Provides access to survey package related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  Retrieve list of available survey packages

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__surveypackage)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/surveypackage", client, params)
  end

  @doc """
  Retrieve a single survey package

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__surveypackage__survey_package_id_)
  """
  def find(%Client{} = client, study_id, survey_package_id) do
    get("api/study/" <> study_id <> "/surveypackage/" <> survey_package_id, client)
  end
end
