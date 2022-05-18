defmodule CastorEDC.StudyProtocol.ReportSteps do
  @moduledoc """
  Provides access to report step related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all report steps

  [More info](https://data.castoredc.com/api#/report-step/get_study__study_id__report__report_id__report_step)
  """
  def list(%Client{} = client, study_id, report_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/report/" <> report_id <> "/report-step",
      client,
      params
    )
  end

  @doc """
  Find a specific report step

  [More info](https://data.castoredc.com/api#/report-step/get_study__study_id__report__report_id__report_step__report_step_id_)
  """
  def find(%Client{} = client, study_id, report_id, report_step_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/report/" <> report_id <> "/report-step/" <> report_step_id,
      client,
      params
    )
  end
end
