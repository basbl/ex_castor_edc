defmodule CastorEDC.StudyProtocol.Visits do
  @moduledoc """
  Provides access to visit related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all visits

  [More info](https://data.castoredc.com/api#/visit/get_study__study_id__visit)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/visit",
      client,
      params
    )
  end

  @doc """
  Find a specific visit

  [More info](https://data.castoredc.com/api#/visit/get_study__study_id__visit__visit_id_)
  """
  def find(%Client{} = client, study_id, visit_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/visit/" <> visit_id,
      client,
      params
    )
  end
end
