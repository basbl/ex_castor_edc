defmodule CastorEDC.DataCollection.SurveyPackageInstances do
  @moduledoc """
  Provides access to survey package instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all survey package instances

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__surveypackageinstance)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/surveypackageinstance", client, params)
  end

  @doc """
  Find a specific survey package instance

  [More info](https://data.castoredc.com/api#/survey/get_study__study_id__surveypackageinstance__survey_package_instance_id_)
  """
  def find(%Client{} = client, study_id, survey_package_instance_id) do
    get(
      "api/study/" <> study_id <> "/surveypackageinstance/" <> survey_package_instance_id,
      client
    )
  end

  @doc """
  Creates a SurveyPackageInstance and (optionally) send the email invite directly.

  [More info](https://data.castoredc.com/api#/survey/post_study__study_id__surveypackageinstance)
  """
  def create(%Client{} = client, study_id, body) do
    post("api/study/" <> study_id <> "/surveypackageinstance", client, body)
  end

  @doc """
  Locks/unlocks a SurveyPackageInstance.

  [More info](https://data.castoredc.com/api#/survey/patch_study__study_id__surveypackageinstance__survey_package_instance_id_)
  """
  def patch(%Client{} = client, study_id, survey_package_instance_id, body) do
    patch(
      "api/study/" <> study_id <> "/surveypackageinstance/" <> survey_package_instance_id,
      client,
      body
    )
  end
end
