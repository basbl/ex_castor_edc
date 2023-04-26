defmodule CastorEDC.DataCollection.RepeatingDataInstances do
  @moduledoc """
  Provides access to repeating data instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all repeating data instances

  [More info](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__repeating_data_instance)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/repeating-data-instance", client, params)
  end

  @doc """
  Find a specific repeating data instance

  [More info](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__repeating_data_instance__repeating_data_instance_id_)
  """
  def find(%Client{} = client, study_id, repeating_data_instance_id) do
    get(
      "api/study/" <> study_id <> "/repeating-data-instance/" <> repeating_data_instance_id,
      client
    )
  end
end
