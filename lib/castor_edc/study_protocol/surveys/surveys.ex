defmodule CastorEDC.StudyProtocol.Surveys do
  @moduledoc """
  Provides access to survey related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all surveys

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__survey)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/survey", client, params)
  end

  @doc """
  Find a specific survey

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__survey__survey_id_)
  """
  def find(%Client{} = client, study_id, survey_id) do
    get("api/study/" <> study_id <> "/survey/" <> survey_id, client)
  end
end
