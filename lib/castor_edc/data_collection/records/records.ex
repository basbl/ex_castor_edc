defmodule CastorEDC.DataCollection.Records do
  @moduledoc """
  Provides access to record related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all records

  [More info](https://data.castoredc.com/api#/record/get_study__study_id__record)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/record", client, params)
  end

  @doc """
  Find a specific record

  [More info](https://data.castoredc.com/api#/record/get_study__study_id__record__record_id_)
  """
  def find(%Client{} = client, study_id, record_id) do
    get("api/study/" <> study_id <> "/record/" <> record_id, client)
  end

  @doc """
  Create a new record

  [More info](https://data.castoredc.com/api#/record/post_study__study_id__record)
  """
  def create(%Client{} = client, study_id, body) when is_map(body) do
    post("api/study/" <> study_id <> "/record", client, body)
  end
end
