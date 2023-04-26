defmodule CastorEDC.Common.Sites do
  @moduledoc """
  Provides access to site related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all sites

  [More info](https://data.castoredc.com/api#/site/get_study__study_id__site)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/site",
      client,
      params
    )
  end

  @doc """
  Find a specific site

  [More info](https://data.castoredc.com/api#/site/get_study__study_id__site__site_id_)
  """
  def find(%Client{} = client, study_id, site_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/site/" <> site_id,
      client,
      params
    )
  end

  @doc """
  Create a single or multiple new site(s)

  [More info](https://data.castoredc.com/api#/site/post_study__study_id__site)
  """
  def create(%Client{} = client, study_id, body) when is_map(body) do
    post("api/study/" <> study_id <> "/site", client, [body])
  end

  def create(%Client{} = client, study_id, body) when is_list(body) do
    post("api/study/" <> study_id <> "/site", client, body)
  end
end
