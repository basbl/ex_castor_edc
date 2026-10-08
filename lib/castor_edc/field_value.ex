defmodule CastorEDC.FieldValue do
  @moduledoc """
  Turns the values of data points into Elixir values.

  The API sends every value as a string, the way it's stored, whatever the
  field's type. `decode/2` reads it according to the field's type:

  | Field type | Stored as | Decoded to |
  | --- | --- | --- |
  | `numeric`, `slider` | `"42"`, `"3.14"` | an integer or a float |
  | `year` | `"2015"` | an integer |
  | `calculation` | the result | a number when it is one, otherwise the string |
  | `date` | `"07-10-2026"`, or `"07102026"` in older data | a `Date` |
  | `date_partial` | `"00-05-2020"`, with `00` for unknown parts | a `CastorEDC.PartialDate` |
  | `time` | `"12:30"` | a `Time` |
  | `datetime` | `"07-10-2026;12:30"` | a `NaiveDateTime` |
  | `numberdate` | `"5;07-10-2026"` | `{number, date}`, either of which can be `nil` |
  | `string`, `textarea` and others | text | the string |
  | any, when empty | `""` | `nil` |
  | any, when marked missing | `"##USER_MISSING_95##"` to `"##USER_MISSING_99##"` | a `CastorEDC.MissingValue` |
  | any, when encrypted | `"*encrypted*"` | `:encrypted` |

  Layout types without values, such as `remark` and `repeated_measures`,
  decode like text.

  `decode/2` never raises. A value that doesn't read as its type comes back
  as the string it arrived as, and the first such value of each field logs
  a warning.
  """

  alias CastorEDC.MissingValue
  alias CastorEDC.Model.Field
  alias CastorEDC.PartialDate

  require Logger

  @type t ::
          nil
          | String.t()
          | integer()
          | float()
          | Date.t()
          | PartialDate.t()
          | Time.t()
          | NaiveDateTime.t()
          | {integer() | float() | nil, Date.t() | nil}
          | MissingValue.t()
          | :encrypted

  @encrypted "*encrypted*"
  @warnings :castor_edc_warnings

  @doc """
  Decodes a stored value for the field it belongs to.

  `field` is a `CastorEDC.Model.Field`, or just its type, such as
  `"numeric"`.

      iex> CastorEDC.FieldValue.decode("42", "numeric")
      42
      iex> CastorEDC.FieldValue.decode("##USER_MISSING_96##", "numeric")
      %CastorEDC.MissingValue{code: 96, reason: :not_applicable}
      iex> CastorEDC.FieldValue.decode("", "year")
      nil
  """
  @spec decode(String.t() | nil, Field.t() | String.t()) :: t()
  def decode(raw, field)
  def decode(nil, _field), do: nil
  def decode("", _field), do: nil
  def decode(@encrypted, _field), do: :encrypted

  def decode(raw, field) when is_binary(raw) do
    with nil <- MissingValue.parse(raw) do
      case read(type(field), raw) do
        {:ok, value} ->
          value

        :error ->
          warn(raw, field)
          raw
      end
    end
  end

  defp type(%Field{field_type: type}), do: type
  defp type(type) when is_binary(type), do: type

  defp read(type, raw) when type in ["numeric", "slider"], do: number(raw)
  defp read("year", raw), do: integer(raw)

  defp read("calculation", raw) do
    case number(raw) do
      {:ok, number} -> {:ok, number}
      :error -> {:ok, raw}
    end
  end

  defp read("date", raw), do: date(raw)
  defp read("date_partial", raw), do: partial_date(raw)
  defp read("time", raw), do: time(raw)

  defp read("datetime", raw) do
    with [date, time] <- String.split(raw, ";"),
         {:ok, date} <- date(date),
         {:ok, time} <- time(time) do
      {:ok, NaiveDateTime.new!(date, time)}
    else
      _invalid -> :error
    end
  end

  defp read("numberdate", raw) do
    with [number, date] <- String.split(raw, ";"),
         {:ok, number} <- optional(number, &number/1),
         {:ok, date} <- optional(date, &date/1) do
      {:ok, {number, date}}
    else
      _invalid -> :error
    end
  end

  defp read(_text, raw), do: {:ok, raw}

  defp optional("", _read), do: {:ok, nil}
  defp optional(raw, read), do: read.(raw)

  defp date(raw) do
    with {:ok, {year, month, day}} <- date_parts(raw),
         {:ok, date} <- Date.new(year, month, day) do
      {:ok, date}
    else
      _invalid -> :error
    end
  end

  defp partial_date(raw) do
    with {:ok, {year, month, day}} <- date_parts(raw),
         {:ok, partial_date} <- PartialDate.new(year, unknown(month), unknown(day)) do
      {:ok, partial_date}
    else
      _invalid -> :error
    end
  end

  defp unknown(0), do: nil
  defp unknown(part), do: part

  # dd-mm-yyyy, or ddmmyyyy as older data has it.
  defp date_parts(<<day::binary-size(2), "-", month::binary-size(2), "-", year::binary-size(4)>>),
    do: date_parts(day <> month <> year)

  defp date_parts(<<day::binary-size(2), month::binary-size(2), year::binary-size(4)>>) do
    with {:ok, day} <- digits(day), {:ok, month} <- digits(month), {:ok, year} <- digits(year) do
      {:ok, {year, month, day}}
    end
  end

  defp date_parts(_raw), do: :error

  defp time(raw) do
    case Time.from_iso8601(if byte_size(raw) == 5, do: raw <> ":00", else: raw) do
      {:ok, time} -> {:ok, time}
      {:error, _reason} -> :error
    end
  end

  defp digits(raw) do
    if raw =~ ~r/\A\d+\z/, do: integer(raw), else: :error
  end

  defp number(raw) do
    with :error <- integer(raw) do
      case Float.parse(raw) do
        {float, ""} -> {:ok, float}
        _other -> :error
      end
    end
  end

  defp integer(raw) do
    case Integer.parse(raw) do
      {integer, ""} -> {:ok, integer}
      _other -> :error
    end
  end

  # Once per field (or per type, when only the type is known), so a column
  # of bad values doesn't flood the log.
  defp warn(raw, field) do
    {key, description} =
      case field do
        %Field{id: id, field_variable_name: name} -> {id, "field #{name || id}"}
        type -> {type, "a field"}
      end

    if first_warning?(key) do
      Logger.warning(
        "CastorEDC.FieldValue couldn't read #{inspect(raw)} as a #{type(field)} value of #{description}, " <>
          "and kept the string; it warns once per field"
      )
    end
  end

  defp first_warning?(key) do
    :ets.insert_new(@warnings, {key})
  rescue
    ArgumentError -> true
  end
end
