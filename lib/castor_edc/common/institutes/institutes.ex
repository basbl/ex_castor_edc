defmodule CastorEDC.Common.Institutes do
  @moduledoc """
  Provides access to institute related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all institutes

  [More info](https://data.castoredc.com/api#/institute/get_study__study_id__institute)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/institute",
      client,
      params
    )
  end

  @doc """
  Find a specific institute

  [More info](https://data.castoredc.com/api#/institute/get_study__study_id__institute__institute_id_)
  """
  def find(%Client{} = client, study_id, institute_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/institute/" <> institute_id,
      client,
      params
    )
  end

  @doc """
  Create a single or multiple new institute(s)

  [More info](https://data.castoredc.com/api#/institute/post_study__study_id__institute)
  """
  def create(%Client{} = client, study_id, body) when is_map(body) do
    post("api/study/" <> study_id <> "/institute", client, [body])
  end

  def create(%Client{} = client, study_id, body) when is_list(body) do
    post("api/study/" <> study_id <> "/institute", client, body)
  end
end
