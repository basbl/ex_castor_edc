defmodule CastorEDC.Common.Studies.Roles do
  @moduledoc """
  Provides access to role related endpoints within the study context
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all roles available within the study

  [More info](https://data.castoredc.com/api#/role/get_study__study_id__role)
  """
  def list(%Client{} = client, study_id) do
    get("api/study/" <> study_id <> "/role", client)
  end

  @doc """
  Find a specific role within the study

  [More info](https://data.castoredc.com/api#/role/get_study__study_id__role__role_name_)
  """
  def find(%Client{} = client, study_id, role_name) do
    get("api/study/" <> study_id <> "/role/" <> role_name, client)
  end

  @doc """
  Create a new role

  [More info](https://data.castoredc.com/api#/role/post_study__study_id__role)
  """
  def create(%Client{} = client, study_id, body) when is_map(body) do
    post("api/study/" <> study_id <> "/role", client, body)
  end
end
