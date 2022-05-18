defmodule CastorEDC.DataCollection.Verifications do
  @moduledoc """
  Provides access to verification related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all verifications

  [More info](https://data.castoredc.com/api#/verification/get_study__study_id__verification)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/verification", client, params)
  end
end
