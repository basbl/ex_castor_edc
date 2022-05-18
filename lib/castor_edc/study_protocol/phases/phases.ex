defmodule CastorEDC.StudyProtocol.Phases do
  @moduledoc """
  Provides access to phase related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all phases

  [More info](https://data.castoredc.com/api#/phase/get_study__study_id__phase)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/phase",
      client,
      params
    )
  end

  @doc """
  Find a specific phase

  [More info](https://data.castoredc.com/api#/phase/get_study__study_id__phase__phase_id_)
  """
  def find(%Client{} = client, study_id, phase_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/phase/" <> phase_id,
      client,
      params
    )
  end
end
