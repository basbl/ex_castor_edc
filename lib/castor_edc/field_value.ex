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
  | `radio`, `dropdown` | the chosen option's value, such as `"2"` | the value, as a string |
  | `checkbox` | the checked options' values, such as `"0;1"` | a list of the values |
  | `grid` (the API doesn't take grid values in writes) | JSON, row by column: `{"0":{"0":"5"}}` | `%{row => %{column => cell}}`, with integer rows and columns; given the field, each cell decoded by its row's or column's type from the grid's layout, and like text otherwise |
  | `upload` | `"-- Uploaded File: scan.pdf --"` from single data points, `"- - Uploaded file - -"` when the name can't be read, or JSON with the name base64-encoded (`{"file_name":"c2Nhbi5wZGY=",...}`) from the lists | `{:upload, name}`, with `nil` for an unknown name |
  | `geolocation` | `"52.36;4.90"` | `{latitude, longitude}` |
  | `string`, `textarea` and others | text | the string |
  | any, when empty | `""` | `nil` |
  | any, when marked missing | `"##USER_MISSING_95##"` to `"##USER_MISSING_99##"` | a `CastorEDC.MissingValue` |
  | any, when encrypted | `"*encrypted*"` | `:encrypted` |

  Layout types without values, such as `remark` and `repeated_measures`,
  decode like text.

  Options are stored by value, not by name: `label/2` looks up the name the
  user saw.

  `decode/2` never raises. A value that doesn't read as its type comes back
  as the string it arrived as, and the first such value of each field logs
  a warning.
  """

  alias CastorEDC.MissingValue
  alias CastorEDC.Model.Field
  alias CastorEDC.Model.FieldOptionGroup
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
          | [String.t()]
          | %{
              optional(integer() | String.t()) => %{
                optional(integer() | String.t()) => String.t() | MissingValue.t() | :encrypted | nil
              }
            }
          | {:upload, String.t() | nil}
          | {float(), float()}
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
  @spec decode(String.t() | nil, Field.t() | String.t() | atom()) :: t()
  def decode(raw, field)
  def decode(nil, _field), do: nil
  def decode("", _field), do: nil
  def decode(@encrypted, _field), do: :encrypted

  def decode(raw, field) when is_binary(raw) do
    with nil <- MissingValue.parse(raw) do
      case read(type(field), raw) do
        {:ok, value} ->
          typed_cells(value, field)

        :error ->
          warn(raw, field)
          raw
      end
    end
  end

  # A grid's layout (its field's summary template) gives each row, or each
  # column, a field type; its cells decode as that type when the field is
  # given, and as text otherwise.
  defp typed_cells(grid, %Field{field_type: "grid", field_summary_template: template})
       when is_map(grid) and is_binary(template) do
    case JSON.decode(template) do
      {:ok, %{"type" => by, "fieldTypes" => types}} when by in ["row", "column"] and is_list(types) ->
        Map.new(grid, fn {row, cells} ->
          {row,
           Map.new(cells, fn {column, cell} ->
             {column, retype(cell, Enum.at(types, if(by == "row", do: row, else: column)))}
           end)}
        end)

      _other ->
        grid
    end
  end

  defp typed_cells(value, _field), do: value

  defp retype(cell, type) when is_binary(cell) and is_binary(type) and type not in ["", "string", "textarea"],
    do: decode(cell, type)

  defp retype(cell, _type), do: cell

  @doc """
  The name of the option with the given value, as the user saw it.

  `options` is the field's `CastorEDC.Model.FieldOptionGroup`, or the field
  itself when it was listed with `include: "optiongroup"`. A list of values,
  as a checkbox field has, gives a list of names. A value the option group
  doesn't have gives `nil`.

      iex> yes = %CastorEDC.Model.FieldOption{value: "1", name: "Yes"}
      iex> no = %CastorEDC.Model.FieldOption{value: "0", name: "No"}
      iex> group = %CastorEDC.Model.FieldOptionGroup{options: [yes, no]}
      iex> CastorEDC.FieldValue.label("1", group)
      "Yes"
      iex> CastorEDC.FieldValue.label(["0", "1"], group)
      ["No", "Yes"]
  """
  @spec label(String.t() | [String.t()], FieldOptionGroup.t() | Field.t() | nil) ::
          String.t() | [String.t() | nil] | nil
  def label(values, options) when is_list(values), do: Enum.map(values, &label(&1, options))
  def label(value, %Field{option_group: group}), do: label(value, group)

  def label(value, %FieldOptionGroup{options: options}) when is_binary(value) do
    Enum.find_value(options || [], fn option -> if option.value == value, do: option.name end)
  end

  def label(_value, _options), do: nil

  defp type(%Field{field_type: type}), do: type
  defp type(type) when is_binary(type), do: type
  defp type(type) when is_atom(type), do: Atom.to_string(type)

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

  defp read("checkbox", raw), do: {:ok, String.split(raw, ";")}

  defp read("grid", raw) do
    with {:ok, rows} when is_map(rows) <- JSON.decode(raw),
         true <- Enum.all?(rows, fn {_row, cells} -> is_map(cells) end) do
      {:ok, Map.new(rows, fn {row, cells} -> {key(row), Map.new(cells, &cell/1)} end)}
    else
      _invalid -> :error
    end
  end

  defp read("upload", "- - Uploaded file - -"), do: {:ok, {:upload, nil}}

  defp read("upload", "-- Uploaded File: " <> rest) do
    case String.split_at(rest, -3) do
      {name, " --"} -> {:ok, {:upload, name}}
      _invalid -> :error
    end
  end

  # The data point lists describe an upload as JSON, with the file's name
  # base64-encoded; its type, size and storage path are in the raw value.
  defp read("upload", "{" <> _rest = raw) do
    with {:ok, %{"file_name" => encoded}} when is_binary(encoded) <- JSON.decode(raw),
         {:ok, name} <- Base.decode64(encoded) do
      {:ok, {:upload, name}}
    else
      _unreadable -> :error
    end
  end

  defp read("upload", _raw), do: :error

  defp read("geolocation", raw) do
    with [latitude, longitude] <- String.split(raw, ";"),
         {:ok, latitude} <- coordinate(latitude),
         {:ok, longitude} <- coordinate(longitude) do
      {:ok, {latitude, longitude}}
    else
      _invalid -> :error
    end
  end

  defp read(_text, raw), do: {:ok, raw}

  defp key(key) do
    case Integer.parse(key) do
      {integer, ""} -> integer
      _other -> key
    end
  end

  defp cell({column, value}) when is_binary(value), do: {key(column), decode(value, "string")}
  defp cell({column, value}) when is_number(value), do: {key(column), to_string(value)}
  defp cell({column, _value}), do: {key(column), nil}

  defp coordinate(raw) do
    case number(String.trim(raw)) do
      {:ok, number} -> {:ok, number / 1}
      :error -> :error
    end
  end

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
