defmodule CastorEDC.DataCollection.Randomization do
  @moduledoc """
  Provides access to randomization related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  Find randomization details of a record

  [More info](https://data.castoredc.com/api#/randomization/get_study__study_id__record__record_id__randomization)
  """
  def find(%Client{} = client, study_id, record_id) do
    get("api/study/" <> study_id <> "/record/" <> record_id <> "/randomization", client)
  end

  @doc """
  Randomize a record

  [More info](https://data.castoredc.com/api#/randomization/post_study__study_id__record__record_id__randomization)
  """
  def create(%Client{} = client, study_id, record_id) do
    post("api/study/" <> study_id <> "/record/" <> record_id <> "/randomization", client, %{})
  end
end
