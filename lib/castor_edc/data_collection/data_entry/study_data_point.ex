defmodule CastorEDC.DataCollection.DataEntry.StudyDataPoint do
  @moduledoc """
  Provides access to study data point related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client
  alias Tesla.Multipart

  @doc """
  List all collected study data points for a participant

  [More info](https://data.castoredc.com/api#/study-data-entry/get_study__study_id__participant__participant_id__data_point_study)
  """
  def list(%Client{} = client, study_id, participant_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/participant/" <> participant_id <> "/data-point/study",
      client,
      params
    )
  end

  @doc """
  Find collected study data point for a participant in a field

  [More info](https://data.castoredc.com/api#/study-data-entry/get_study__study_id__participant__participant_id__study_data_point__field_id_)
  """
  def find(%Client{} = client, study_id, participant_id, field_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/participant/" <> participant_id <> "/data-point/study/" <> field_id,
      client,
      params
    )
  end

  @doc """
  Create a new data point for a participant

  [More info](https://data.castoredc.com/api#/study-data-entry/post_study__study_id__participant__participant_id__study_data_point__field_id_)
  """
  def create(%Client{} = client, study_id, participant_id, field_id, %{"field_value" => _} = body) do
    post(
      "api/study/" <>
        study_id <> "/participant/" <> participant_id <> "/data-point/study/" <> field_id,
      client,
      body
    )
  end

  def create(
        %Client{} = client,
        study_id,
        participant_id,
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
        study_id <> "/participant/" <> participant_id <> "/data-point/study/" <> field_id,
      client,
      mp
    )
  end
end
