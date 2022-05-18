defmodule CastorEDC.Common.Studies.Users do
  @moduledoc """
  Provides access to user related endpoints within the study context
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all users that have access to the given study

  [More info](https://data.castoredc.com/api#/study/get_study__study_id__user)
  """
  def list(%Client{} = client, study_id) do
    get("api/study/" <> study_id <> "/user", client)
  end

  @doc """
  Find a specific user that has access to the study

  [More info](https://data.castoredc.com/api#/study/get_study__study_id__user__user_id_)
  """
  def find(%Client{} = client, study_id, user_id) do
    get("api/study/" <> study_id <> "/user/" <> user_id, client)
  end
end
