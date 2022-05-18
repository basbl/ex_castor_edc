defmodule CastorEDC.DataCollection.Statistics do
  @moduledoc """
  Provides access to statistics related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  Find study statistics

  [More info](https://data.castoredc.com/api#/study-statistics/get_study__study_id__statistics)
  """
  def find(%Client{} = client, study_id) do
    get("api/study/" <> study_id <> "/statistics", client)
  end
end
