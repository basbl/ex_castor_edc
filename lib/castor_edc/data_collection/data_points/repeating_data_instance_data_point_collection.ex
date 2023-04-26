defmodule CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection do
  @moduledoc """
  Provides access to repeating data instance data point collection for all participants
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected data points for repeating data instances

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_repeating_data_instance)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/data-points/repeating-data-instance",
      client,
      params
    )
  end

  @doc """
  List all collected data points for a specific repeating data instance

  [More info](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_repeating_data_instance__repeating_data_instance_id_)
  """
  def find(%Client{} = client, study_id, repeating_data_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/data-points/repeating-data-instance/" <> repeating_data_instance_id,
      client,
      params
    )
  end

  @doc """
  Create/update a collection of field values for a repeating data instance

  [More info](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_repeating_data_instance__repeating_data_instance_id_)
  """
  def create(%Client{} = client, study_id, participant_id, repeating_data_instance_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/participant/" <>
        participant_id <> "/data-points/repeating-data-instance/" <> repeating_data_instance_id,
      client,
      body
    )
  end
end
