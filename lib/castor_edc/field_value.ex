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

  require Logger

  @type t :: nil | String.t() | integer() | float() | MissingValue.t() | :encrypted

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

  defp read(_text, raw), do: {:ok, raw}

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
