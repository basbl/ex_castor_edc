defmodule CastorEDC.StudyProtocol.Forms do
  @moduledoc """
  Provides access to form related endpoints within the study context
  """

  import CastorEDC
  alias CastorEDC.Client

  @spec list(CastorEDC.Client.t(), binary, []) :: {integer, %{}, Tesla.Env.t()}
  @doc """
  List all forms

  [More info](https://data.castoredc.com/api#/form/get_study__study_id__form)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/form",
      client,
      params
    )
  end

  @doc """
  Find a specific form

  [More info](https://data.castoredc.com/api#/form/get_study__study_id__form__form_id_)
  """
  def find(%Client{} = client, study_id, form_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/form/" <> form_id,
      client,
      params
    )
  end
end
