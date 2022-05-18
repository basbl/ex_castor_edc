defmodule CastorEDC.StudyProtocol.FieldValidations do
  @moduledoc """
  Provides access to field validation related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all field validations

  [More info](https://data.castoredc.com/api#/field-validation/get_study__study_id__field_validation)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-validation",
      client,
      params
    )
  end

  @doc """
  Find a specific field validation

  [More info](https://data.castoredc.com/api#/field-validation/get_study__study_id__field_validation__fieldValidation_id_)
  """
  def find(%Client{} = client, study_id, field_validation_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-validation/" <> field_validation_id,
      client,
      params
    )
  end
end
