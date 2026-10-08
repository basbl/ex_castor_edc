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

  for type <-
        ~w(numeric year calculation string textarea date date_partial time datetime numberdate radio dropdown checkbox grid upload geolocation) do
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
  defp valid?("date", value), do: is_struct(value, Date)
  defp valid?("date_partial", value), do: is_struct(value, CastorEDC.PartialDate)
  defp valid?("time", value), do: is_struct(value, Time)
  defp valid?("datetime", value), do: is_struct(value, NaiveDateTime)

  defp valid?("numberdate", {number, date}),
    do: (is_number(number) or is_nil(number)) and (is_nil(date) or is_struct(date, Date))

  defp valid?("numberdate", _value), do: false
  defp valid?(option, value) when option in ["radio", "dropdown"], do: is_binary(value)
  defp valid?("checkbox", values), do: is_list(values) and Enum.all?(values, &is_binary/1)
  defp valid?("grid", rows), do: is_map(rows) and Enum.all?(rows, fn {_row, cells} -> is_map(cells) end)
  defp valid?("upload", value), do: match?({:upload, _name}, value)

  defp valid?("geolocation", value),
    do: match?({latitude, longitude} when is_float(latitude) and is_float(longitude), value)

  test "finds the name of every chosen option", %{values: values} do
    for {%{field_type: type} = field, raw} <- values, type in ~w(radio dropdown checkbox) do
      case FieldValue.decode(raw, field) do
        value when is_binary(value) or is_list(value) ->
          assert value |> List.wrap() |> FieldValue.label(field) |> Enum.all?(&is_binary/1),
                 "#{inspect(value)} isn't in the option group of #{field.field_variable_name}"

        _empty_or_missing ->
          :ok
      end
    end
  end
end
