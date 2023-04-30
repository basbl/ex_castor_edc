defmodule CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint do
  @moduledoc """
  Provides access to repeating data data point related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client
  alias Tesla.Multipart

  @doc """
  List all collected repeating data instance data points for a participant

  [More info](https://data.castoredc.com/api#/repeating-data-data-entry/get_study__study_id__participant__participant_id__data_point_repeating_data__repeating_data_instance_id_)
  """
  def list(%Client{} = client, study_id, participant_id, repeating_data_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/participant/" <> participant_id <> "/data-point/repeating-data/" <> repeating_data_instance_id,
      client,
      params
    )
  end

  @doc """
  Find a data point for a participant in a specific repeating data instance

  [More info](https://data.castoredc.com/api#/repeating-data-data-entry/get_study__study_id__participant__participant_id__data_point_repeating_data__repeating_data_instance_id___field_id_)
  """
  def find(%Client{} = client, study_id, participant_id, repeating_data_instance_id, field_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/participant/" <> participant_id <> "/data-point/repeating-data/" <> repeating_data_instance_id <> "/" <> field_id,
      client,
      params
    )
  end

  @doc """
  Create a new data point in a specific repeating data instance for a participant

  [More info](https://data.castoredc.com/api#/repeating-data-data-entry/post_study__study_id__participant__participant_id__data_point_repeating_data__repeating_data_instance_id___field_id_)
  """
  def create(
        %Client{} = client,
        study_id,
        participant_id,
        repeating_data_instance_id,
        field_id,
        %{"field_value" => _} = body
      ) do
    post(
      "api/study/" <>
        study_id <>
        "/participant/" <> participant_id <> "/data-point/repeating-data/" <> repeating_data_instance_id <> "/" <> field_id,
      client,
      body
    )
  end

  def create(
        %Client{} = client,
        study_id,
        participant_id,
        repeating_data_instance_id,
        field_id,
        %{"upload_file" => file} = body
      ) do
    mp =
      body
      |> Map.drop(["upload_file"])
      |> Enum.reduce(Multipart.new(), fn {k, v}, mp -> Multipart.add_field(mp, k, v) end)
      |> Multipart.add_file(file, name: "upload_file")

    post(
      "api/study/" <>
        study_id <>
        "/participant/" <> participant_id <> "/data-point/repeating-data/" <> repeating_data_instance_id <> "/" <> field_id,
      client,
      mp
    )
  end
end
