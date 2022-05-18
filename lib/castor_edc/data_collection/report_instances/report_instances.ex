defmodule CastorEDC.DataCollection.ReportInstances do
  @moduledoc """
  Provides access to report instance related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all report instances

  [More info](https://data.castoredc.com/api#/report-instance/get_study__study_id__report_instance)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/report-instance", client, params)
  end

  @doc """
  Find a specific report instance

  [More info](https://data.castoredc.com/api#/report-instance/get_study__study_id__report_instance__report_instance_id_)
  """
  def find(%Client{} = client, study_id, report_instance_id) do
    get("api/study/" <> study_id <> "/report-instance/" <> report_instance_id, client)
  end
end
