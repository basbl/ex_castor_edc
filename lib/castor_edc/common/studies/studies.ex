defmodule CastorEDC.Common.Studies do
  @moduledoc """
  Provides access to study related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all studies that the authenticated user is authorized to see

  [More info](https://data.castoredc.com/api#/user/get_user)
  """
  def list(%Client{} = client) do
    get("api/study", client)
  end

  @doc """
  Find a specific study

  [More info](https://data.castoredc.com/api#/study/get_study__study_id_)
  """
  def find(%Client{} = client, study_id) do
    get("api/study/" <> study_id, client)
  end
end
