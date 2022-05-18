defmodule CastorEDC.DataCollection.DataEntry.ReportDataPoint do
  @moduledoc """
  Provides access to report data point related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all collected report instance data points for a record

  [More info](https://data.castoredc.com/api#/report-data-entry/get_study__study_id__record__record_id__data_point_report__report_instance_id_)
  """
  def list(%Client{} = client, study_id, record_id, report_instance_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/record/" <> record_id <> "/data-point/report/" <> report_instance_id,
      client,
      params
    )
  end

  @doc """
  Find a data point for a record in a specific report instance

  [More info](https://data.castoredc.com/api#/report-data-entry/get_study__study_id__record__record_id__data_point_report__report_instance_id___field_id_)
  """
  def find(%Client{} = client, study_id, record_id, report_instance_id, field_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/record/" <> record_id <> "/data-point/report/" <> report_instance_id <> "/" <> field_id,
      client,
      params
    )
  end

  @doc """
  Create a new data point in a specific report instance for a record

  [More info](https://data.castoredc.com/api#/report-data-entry/post_study__study_id__record__record_id__data_point_report__report_instance_id___field_id_)
  """
  def create(%Client{} = client, study_id, record_id, report_instance_id, field_id, body) do
    post(
      "api/study/" <>
        study_id <>
        "/record/" <> record_id <> "/data-point/report/" <> report_instance_id <> "/" <> field_id,
      client,
      body
    )
  end
end
