defmodule CastorEDC.Export.Request do
  @moduledoc false
  # Turns `{type, opts}` into an entry of a batch export request, checking
  # the format, filters and options against the request schema of the
  # vendored spec, so a typo raises here rather than coming back from the
  # API as a 400 (or being ignored).

  @spec_path Path.expand("../../../priv/openapi/castor_edc.json", __DIR__)
  @external_resource @spec_path

  @definitions @spec_path
               |> File.read!()
               |> JSON.decode!()
               |> get_in(["components", "schemas", "BatchExportRequest", "properties", "exports", "properties"])
               |> Map.new(fn {type, %{"items" => %{"properties" => properties}}} ->
                 {String.to_atom(type),
                  %{
                    formats: Enum.map(properties["format"]["enum"], &String.to_atom/1),
                    filters: properties["filters"],
                    options: properties["options"]
                  }}
               end)

  @doc false
  @spec types() :: [atom()]
  def types, do: @definitions |> Map.keys() |> Enum.sort()

  @doc false
  @spec definition(atom()) :: %{formats: [atom()], filters: map(), options: map()}
  def definition(type) do
    case @definitions do
      %{^type => definition} ->
        definition

      _unknown ->
        raise ArgumentError,
              "unknown export type #{inspect(type)}; expected one of #{Enum.map_join(types(), ", ", &inspect/1)}"
    end
  end

  @doc false
  @spec encode(atom(), keyword()) :: map()
  def encode(type, opts) do
    definition = definition(type)
    {format, opts} = Keyword.pop(opts, :format, hd(definition.formats))
    {filters, opts} = Keyword.pop(opts, :filters, [])
    {options, opts} = Keyword.pop(opts, :options, [])

    if opts != [] do
      raise ArgumentError,
            "unknown option(s) #{inspect(Keyword.keys(opts))} for a #{type} export; " <>
              "expected :format, :filters and :options"
    end

    format = to_format(format, type, definition.formats)

    %{"format" => format}
    |> put_object("filters", object(filters, definition.filters, "#{type} export filter"))
    |> put_object("options", object(options, definition.options, "#{type} export option"))
  end

  defp to_format(format, type, formats) do
    case Enum.find(formats, &(&1 == format or Atom.to_string(&1) == format)) do
      nil ->
        raise ArgumentError,
              "a #{type} export can't be in format #{inspect(format)}; " <>
                "expected one of #{Enum.map_join(formats, ", ", &inspect/1)}"

      format ->
        Atom.to_string(format)
    end
  end

  defp put_object(entry, _key, empty) when empty == %{}, do: entry
  defp put_object(entry, key, object), do: Map.put(entry, key, object)

  # The value of an object with known keys: a keyword list or a map, with
  # atom or string keys.
  defp object(values, schema, what) when is_list(values) or is_map(values) do
    properties = schema["properties"] || %{}

    Map.new(values, fn {key, value} ->
      name = to_string(key)

      case properties do
        %{^name => property} ->
          {name, value(value, property, "#{what} #{inspect(key)}")}

        _unknown when properties == %{} ->
          raise ArgumentError, "a #{what} #{inspect(key)} isn't supported; there are none"

        _unknown ->
          raise ArgumentError,
                "unknown #{what} #{inspect(key)}; expected one of " <>
                  (properties |> Map.keys() |> Enum.sort() |> Enum.map_join(", ", &":#{&1}"))
      end
    end)
  end

  defp object(values, _schema, what), do: invalid(values, "a keyword list", what)

  defp value(value, %{"type" => "object"} = schema, what), do: object(value, schema, what)

  defp value(values, %{"type" => "array", "items" => items}, what) when is_list(values),
    do: Enum.map(values, &value(&1, items, what))

  defp value(value, %{"type" => "array"}, what), do: invalid(value, "a list", what)

  defp value(value, %{"type" => "boolean"}, _what) when is_boolean(value), do: value
  defp value(value, %{"type" => "boolean"}, what), do: invalid(value, "a boolean", what)

  defp value(value, %{"type" => "integer"}, _what) when is_integer(value), do: value
  defp value(value, %{"type" => "integer"}, what), do: invalid(value, "an integer", what)

  defp value(value, %{"enum" => enum} = schema, what), do: enum_value(value, enum, schema["x-castor-enum-names"], what)

  defp value(%Date{} = date, %{"format" => format}, _what) when format in ["date", "date-time"], do: Date.to_iso8601(date)

  defp value(%DateTime{} = datetime, %{"format" => "date-time"} = schema, what),
    do: value(DateTime.to_naive(datetime), schema, what)

  defp value(%NaiveDateTime{} = datetime, %{"format" => "date-time"}, _what),
    do: Calendar.strftime(datetime, "%Y-%m-%d %H:%M")

  defp value(value, %{"type" => "string"}, _what) when is_binary(value), do: value
  defp value(value, %{"type" => "string", "format" => "date"}, what), do: invalid(value, "a Date or a string", what)
  defp value(value, %{"type" => "string", "format" => "date-time"}, what), do: invalid(value, "a date or a string", what)
  defp value(value, %{"type" => "string"}, what), do: invalid(value, "a string", what)

  # Enum values are given as atoms (`:in_progress` for "In Progress") or as
  # the API's own strings. The spec names some values differently from the
  # wire (`:visit` is sent as "phase").
  defp enum_value(value, enum, names, what) do
    names = names || %{}

    Enum.find(enum, fn wire ->
      value == wire or (is_atom(value) and Atom.to_string(value) in [wire, names[wire], normalize(wire)])
    end) || invalid(value, "one of " <> Enum.map_join(enum, ", ", &inspect(enum_name(&1, names))), what)
  end

  defp enum_name(wire, names), do: String.to_atom(names[wire] || normalize(wire))

  defp normalize(wire), do: wire |> String.downcase() |> String.replace(" ", "_")

  defp invalid(value, expected, what) do
    raise ArgumentError, "expected #{what} to be #{expected}, got: #{inspect(value)}"
  end
end
