defmodule CastorEDC.E2E.FieldValueTest do
  @moduledoc """
  Decoding the test study's data points with `CastorEDC.FieldValue`.
  """

  use CastorEDC.E2ECase, async: false

  import ExUnit.CaptureLog

  alias CastorEDC.DataPoints
  alias CastorEDC.Fields
  alias CastorEDC.FieldValue
  alias CastorEDC.MissingValue

  setup_all %{client: client, study: study} do
    fields = client |> Fields.stream_fields(study, include: "optiongroup") |> Map.new(&{&1.id, &1})

    points =
      Enum.concat([
        DataPoints.stream_study_data_points(client, study),
        DataPoints.stream_repeating_data_data_points(client, study),
        DataPoints.stream_survey_data_points(client, study)
      ])

    %{values: Enum.map(points, &{fields[&1.field_id], &1.value})}
  end

  test "decodes every value without a warning", %{values: values} do
    assert capture_log(fn -> Enum.each(values, fn {field, raw} -> FieldValue.decode(raw, field) end) end) == ""
  end

  for type <- ~w(numeric year calculation string textarea) do
    test "decodes #{type} values", %{values: values} do
      check(values, unquote(type))
    end
  end

  defp check(values, type) do
    decoded =
      for {%{field_type: ^type} = field, raw} <- values,
          value = FieldValue.decode(raw, field),
          not is_nil(value) and not is_struct(value, MissingValue),
          do: value

    if decoded == [] do
      IO.puts("\n#{type} values: skipped, the test study has none")
    else
      for value <- decoded, do: assert(valid?(type, value), "#{inspect(value)} isn't a #{type} value")
    end
  end

  defp valid?("numeric", value), do: is_number(value)
  defp valid?("year", value), do: is_integer(value) and value in 1891..2100
  defp valid?("calculation", value), do: is_number(value) or is_binary(value)
  defp valid?(text, value) when text in ["string", "textarea"], do: is_binary(value)
end
