defmodule CastorEDC.DataCollection.Records.Progress do
  @moduledoc """
  Provides access to record progress related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all record progress

  [More info](https://data.castoredc.com/api#/record-progress/get_study__study_id__record_progress_steps)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/record-progress/steps", client, params)
  end
end
