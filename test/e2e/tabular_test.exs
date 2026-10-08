defmodule CastorEDC.E2E.TabularTest do
  @moduledoc """
  The test study's data through `CastorEDC.Tabular`.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.Tabular

  setup_all %{client: client, study: study} do
    {:ok, schema} = Tabular.schema(client, study)
    %{schema: schema}
  end

  test "places every field in the study, a repeating data or a survey", %{schema: schema} do
    contexts = schema |> Map.values() |> Enum.frequencies_by(& &1.context)

    assert contexts |> Map.keys() |> Enum.sort() == [:repeating_data, :study, :survey]

    for {_id, column} <- schema do
      assert column.variable_name, "#{column.field_id} has no variable name"
      assert column.parent_name && column.form_name
    end
  end

  test "has option groups for every option field", %{schema: schema} do
    for {_id, %{field_type: type} = column} <- schema, type in ~w(radio dropdown checkbox) do
      assert %{options: [_option | _more]} = column.option_group
    end
  end

  test "streams every value with its participant's site and its field", %{client: client, study: study, schema: schema} do
    rows = client |> Tabular.data_points(study, schema: schema) |> Enum.to_list()

    assert rows != []
    assert rows |> Enum.map(& &1.source) |> Enum.uniq() |> Enum.sort() == [:repeating_data, :study, :survey]

    for row <- rows do
      assert row.site_id, "participant #{row.participant_id} has no site"
      assert %{context: context, variable_name: name} = schema[row.field_id]
      assert context == row.source
      assert name == row.variable_name
      assert row.source == :study == is_nil(row.instance_id)
    end
  end
end
