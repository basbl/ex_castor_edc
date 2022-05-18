defmodule CastorEDC.Common.Users do
  @moduledoc """
  Provides access to user related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all users that the authenticated user is authorized to see

  [More info](https://data.castoredc.com/api#/user/get_user)
  """
  def list(%Client{} = client) do
    get("api/user", client)
  end

  @doc """
  Find a specific user

  [More info](https://data.castoredc.com/api#/user/get_user__user_id_)
  """
  def find(%Client{} = client, user_id) do
    get("api/user/" <> user_id, client)
  end
end
