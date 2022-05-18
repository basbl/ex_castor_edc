defmodule CastorEDC.DataCollection.Queries do
  @moduledoc """
  Provides access to query related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all queries

  [More info](https://data.castoredc.com/api#/query/get_study__study_id__query)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/query",
      client,
      params
    )
  end

  @doc """
  Find a specific query

  [More info](https://data.castoredc.com/api#/query/get_study__study_id__query__query_id_)
  """
  def find(%Client{} = client, study_id, query_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/query/" <> query_id,
      client,
      params
    )
  end
end
