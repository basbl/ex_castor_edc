defmodule CastorEDC.StudyProtocol.RepeatingData do
  @moduledoc """
  Provides access to repeating data related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all repeating data

  [More info](https://data.castoredc.com/api#/repeating-data/get_study__study_id__repeating_data)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/repeating-data", client, params)
  end

  @doc """
  Find a specific repeating data

  [More info](https://data.castoredc.com/api#/repeating-data/get_study__study_id__repeating_data__repeating_data_id_)
  """
  def find(%Client{} = client, study_id, repeating_data_id) do
    get("api/study/" <> study_id <> "/repeating-data/" <> repeating_data_id, client)
  end
end
