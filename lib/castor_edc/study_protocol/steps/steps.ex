defmodule CastorEDC.StudyProtocol.Steps do
  @moduledoc """
  Provides access to user related endpoints within the study context
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all steps

  [More info](https://data.castoredc.com/api#/step/get_study__study_id__step)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/step",
      client,
      params
    )
  end

  @doc """
  Find a specific step

  [More info](https://data.castoredc.com/api#/step/get_study__study_id__step__step_id_)
  """
  def find(%Client{} = client, study_id, step_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/step/" <> step_id,
      client,
      params
    )
  end
end
