defmodule CastorEDC.DataCollection.Participants do
  @moduledoc """
  Provides access to participant related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all participants

  [More info](https://data.castoredc.com/api#/participant/get_study__study_id__participant)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/participant", client, params)
  end

  @doc """
  Find a specific participant

  [More info](https://data.castoredc.com/api#/participant/get_study__study_id__participant__participant_id_)
  """
  def find(%Client{} = client, study_id, participant_id) do
    get("api/study/" <> study_id <> "/participant/" <> participant_id, client)
  end

  @doc """
  Create a new participant

  [More info](https://data.castoredc.com/api#/participant/post_study__study_id__participant)
  """
  def create(%Client{} = client, study_id, body) when is_map(body) do
    post("api/study/" <> study_id <> "/participant", client, body)
  end
end
