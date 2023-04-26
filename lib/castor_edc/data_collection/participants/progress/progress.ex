defmodule CastorEDC.DataCollection.Participants.Progress do
  @moduledoc """
  Provides access to participant progress related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all participant progress

  [More info](https://data.castoredc.com/api#/participant-progress/get_study__study_id__participant_progress_forms)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/participant-progress/forms", client, params)
  end
end
