defmodule CastorEDC.StudyProtocol.Reports do
  @moduledoc """
  Provides access to report related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all reports

  [More info](https://data.castoredc.com/api#/report/get_study__study_id__report)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get("api/study/" <> study_id <> "/report", client, params)
  end

  @doc """
  Find a specific report

  [More info](https://data.castoredc.com/api#/report/get_study__study_id__report__report_id_)
  """
  def find(%Client{} = client, study_id, report_id) do
    get("api/study/" <> study_id <> "/report/" <> report_id, client)
  end
end
