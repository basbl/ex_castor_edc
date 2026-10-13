defmodule CastorEDC.Model do
  @moduledoc """
  The structs responses are decoded into, and the helpers that decode them.

  Every response the API documents has a struct under `CastorEDC.Model`,
  generated from the same spec as the operations. Nested objects are
  decoded into their own structs. A field the spec doesn't name is kept,
  under its wire name, in the struct's `extra` map, so a response survives
  the API adding a field; `_links` and `_embedded` are left out.

  The functions here are what the generated `new/1` functions use.
  """

  @doc """
  Decodes one nested object into `module`'s struct.

  `nil` stays `nil`, and anything that isn't an object is passed through as
  it arrived rather than forced into a struct.
  """
  @spec one(term(), module()) :: term()
  def one(nil, _module), do: nil
  def one(data, module) when is_map(data), do: module.new(data)
  def one(data, _module), do: data

  @doc """
  Decodes a list of nested objects.
  """
  @spec list(term(), module()) :: term()
  def list(nil, _module), do: nil
  def list(data, module) when is_list(data), do: Enum.map(data, &one(&1, module))
  def list(data, _module), do: data

  @doc """
  Casts a value the API sends as a string, or in another awkward form.

    * `:integer` - from an integer, a whole float or a numeric string
    * `:naive_datetime` - from `YYYY-MM-DD HH:MM:SS`, the format of data
      point timestamps
    * `:datetime` - from a serialised PHP `DateTime` object
      (`%{"date" => "2026-10-07 21:08:46.000000", "timezone" => "Europe/Amsterdam"}`),
      as the export list sends, or an ISO 8601 string

  It never raises: a value that doesn't cast is returned as it arrived.
  """
  @spec cast(term(), :integer | :naive_datetime | :datetime) :: term()
  def cast(nil, _type), do: nil

  def cast(value, :integer) when is_integer(value), do: value
  def cast(value, :integer) when is_float(value) and value == trunc(value), do: trunc(value)

  def cast(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _other -> value
    end
  end

  def cast(value, :naive_datetime) when is_binary(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive} -> naive
      {:error, _reason} -> value
    end
  end

  def cast(%{"date" => date, "timezone" => zone} = value, :datetime) when is_binary(date) and is_binary(zone) do
    with {:ok, naive} <- NaiveDateTime.from_iso8601(date),
         {:ok, datetime} <- from_naive(naive, zone) do
      datetime
    else
      _other -> value
    end
  end

  def cast(value, :datetime) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      {:error, _reason} -> value
    end
  end

  def cast(value, _type), do: value

  # A local time that falls in a DST overlap or gap still has to become one
  # moment; as PHP does, take the earlier reading of an ambiguous time, and
  # the moment after the gap for a skipped one.
  defp from_naive(naive, "+" <> _offset = zone), do: from_offset(naive, zone)
  defp from_naive(naive, "-" <> _offset = zone), do: from_offset(naive, zone)

  defp from_naive(naive, zone) do
    case DateTime.from_naive(naive, zone, Tz.TimeZoneDatabase) do
      {:ok, datetime} -> {:ok, datetime}
      {:ambiguous, first, _second} -> {:ok, first}
      {:gap, _before, after_gap} -> {:ok, after_gap}
      {:error, reason} -> {:error, reason}
    end
  end

  # PHP's offset zones ("+02:00", timezone_type 1) become UTC.
  defp from_offset(naive, offset) do
    case Regex.run(~r/^([+-])(\d{2}):?(\d{2})$/, offset) do
      [_all, sign, hours, minutes] ->
        seconds = (String.to_integer(hours) * 3600 + String.to_integer(minutes) * 60) * if(sign == "+", do: 1, else: -1)
        {:ok, naive |> NaiveDateTime.add(-seconds) |> DateTime.from_naive!("Etc/UTC")}

      nil ->
        {:error, :invalid_offset}
    end
  end
end
