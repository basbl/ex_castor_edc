defmodule CastorEDC.DataCollection.Records.ReportInstances do
  @moduledoc """
  Provides access to report instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all report instances

  [More info](https://data.castoredc.com/api#/report-instance/get_study__study_id__record__record_id__report_instance)
  """
  def list(%Client{} = client, study_id, record_id, params \\ []) do
    get("api/study/" <> study_id <> "/record/" <> record_id <> "/report-instance", client, params)
  end

  @doc """
  Find a specific report instance

  [More info](https://data.castoredc.com/api#/report-instance/get_study__study_id__record__record_id__report_instance__report_instance_id_)
  """
  def find(%Client{} = client, study_id, record_id, report_instance_id) do
    get(
      "api/study/" <>
        study_id <> "/record/" <> record_id <> "/report-instance/" <> report_instance_id,
      client
    )
  end

  @doc """
  Creates a report instance

  [Single instance](https://data.castoredc.com/api#/report-instance/post_study__study_id__record__record_id__report_instance)
  [Multiple instances](https://data.castoredc.com/api#/report-instance/post_study__study_id__record__record_id__report_instance_collection)
  """
  def create(%Client{} = client, study_id, record_id, body) when is_list(body) do
    post(
      "api/study/" <> study_id <> "/record/" <> record_id <> "/report-instance-collection",
      client,
      %{"data" => body}
    )
  end

  def create(%Client{} = client, study_id, record_id, body) do
    post("api/study/" <> study_id <> "/record/" <> record_id <> "/report-instance", client, body)
  end
end
