defmodule CastorEDC.StudyProtocol.OptionGroups do
  @moduledoc """
  Provides access to option group related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all option groups

  [More info](https://data.castoredc.com/api#/field-optiongroup/get_study__study_id__field_optiongroup)
  """
  def list(%Client{} = client, study_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-optiongroup",
      client,
      params
    )
  end

  @doc """
  Find a specific option group

  [More info](https://data.castoredc.com/api#/field-optiongroup/get_study__study_id__field_optiongroup__optiongroup_id_)
  """
  def find(%Client{} = client, study_id, option_group_id, params \\ []) do
    get(
      "api/study/" <> study_id <> "/field-optiongroup/" <> option_group_id,
      client,
      params
    )
  end
end
