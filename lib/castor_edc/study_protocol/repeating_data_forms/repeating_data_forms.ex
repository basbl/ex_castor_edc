defmodule CastorEDC.StudyProtocol.RepeatingDataForms do
  @moduledoc """
  Provides access to repeating data form related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all repeating data forms

  [More info](https://data.castoredc.com/api#/repeating-data-form/get_study__study_id__repeating_data__repeating_data_id__repeating_data_form)
  """
  def list(%Client{} = client, study_id, repeating_data_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <> "/repeating-data/" <> repeating_data_id <> "/repeating-data-form",
      client,
      params
    )
  end

  @doc """
  Find a specific repeating data form

  [More info](https://data.castoredc.com/api#/repeating-data-form/get_study__study_id__repeating_data__repeating_data_id__repeating_data_form__repeating_data_form_id_)
  """
  def find(%Client{} = client, study_id, repeating_data_id, repeating_data_form_id, params \\ []) do
    get(
      "api/study/" <>
        study_id <>
        "/repeating-data/" <>
        repeating_data_id <> "/repeating-data-form/" <> repeating_data_form_id,
      client,
      params
    )
  end
end
