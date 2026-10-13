defmodule CastorEDC.Export.Request do
  @moduledoc false
  # Turns `{type, opts}` into an entry of a batch export request, checking
  # the format, filters and options against the request schema of the
  # vendored spec, so a typo raises here rather than coming back from the
  # API as a 400 (or being ignored).

  # The zone of the API's times without one, on data.castoredc.com.
  @server_time_zone "Europe/Amsterdam"

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
  # The formats, filters and options of a type, as Markdown for its docs.
  @spec doc(atom()) :: String.t()
  def doc(type) do
    definition = definition(type)

    formats =
      "Formats: #{Enum.map_join(definition.formats, ", ", &"`#{inspect(&1)}`")} " <>
        "(`#{inspect(hd(definition.formats))}` by default)."

    Enum.join([formats, list_doc("Filters", definition.filters), list_doc("Options", definition.options)], "\n\n")
  end

  defp list_doc(title, schema) do
    case schema["properties"] do
      empty when empty in [nil, %{}] ->
        "#{title}: none."

      properties ->
        requires = schema["x-castor-requires"] || %{}

        items =
          properties
          |> Enum.sort_by(&elem(&1, 0))
          |> Enum.map(fn {name, property} ->
            "  * `:#{name}` (#{type_doc(property)})" <> details_doc(property["description"], requires[name])
          end)

        Enum.join(["#{title}:", "" | items], "\n")
    end
  end

  defp type_doc(%{"type" => "object", "properties" => properties}) do
    keys = properties |> Map.keys() |> Enum.sort() |> Enum.map_join(", ", &"`:#{&1}`")
    "a keyword list of #{keys}, each a list of IDs"
  end

  defp type_doc(%{"type" => "array", "items" => %{"enum" => enum} = items}),
    do: "a list of values from " <> enum_doc(enum, items["x-castor-enum-names"] || %{})

  defp type_doc(%{"type" => "array"}), do: "a list of strings"
  defp type_doc(%{"type" => "boolean"} = property), do: "boolean" <> default_doc(property)
  defp type_doc(%{"type" => "integer"}), do: "integer"

  defp type_doc(%{"enum" => enum} = property) do
    names = property["x-castor-enum-names"] || %{}
    "one of " <> enum_doc(enum, names) <> default_doc(property, &inspect(enum_name(&1, names)))
  end

  defp type_doc(%{"format" => "date"}), do: "a `Date`"

  defp type_doc(%{"format" => "date-time"}),
    do: "a `Date`, a `NaiveDateTime` in the server's time (Europe/Amsterdam) or a `DateTime`, to the minute"

  defp type_doc(_string), do: "string"

  defp enum_doc(enum, names), do: Enum.map_join(enum, ", ", &"`#{inspect(enum_name(&1, names))}`")

  defp default_doc(property, format \\ &inspect/1) do
    case Map.fetch(property, "default") do
      {:ok, default} -> "; `#{format.(default)}` by default"
      :error -> ""
    end
  end

  defp details_doc(nil, nil), do: ""
  defp details_doc(description, nil), do: " - " <> description_text(description)
  defp details_doc(nil, requirement), do: " - Only applies #{requirement_doc(requirement)}."

  defp details_doc(description, requirement) do
    text = description_text(description)
    text = if text =~ ~r/[.!?]\z/, do: text, else: text <> "."
    " - #{text} Only applies #{requirement_doc(requirement)}."
  end

  defp description_text(description) do
    description
    |> String.replace(~r"(?<=[^.!?\s>])\s*(<br\s*/?>)+", ". ")
    |> String.replace(~r"(<br\s*/?>)+", " ")
    |> String.replace(~r"\s+", " ")
    |> String.trim()
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
    options = object(options, definition.options, "#{type} export option")
    check_requires(options, format, definition.options["x-castor-requires"], type)

    %{"format" => format}
    |> put_object("filters", object(filters, definition.filters, "#{type} export filter"))
    |> put_object("options", options)
  end

  # Options that apply only to some formats, and to the grouped export or
  # the default one, as `x-castor-requires` says.
  defp check_requires(_options, _format, nil, _type), do: :ok

  defp check_requires(options, format, requires, type) do
    grouped = options["grouped"] == true

    for {name, _value} <- options, requirement = requires[name], not met?(requirement, format, grouped) do
      raise ArgumentError,
            "the #{type} export option :#{name} only applies #{requirement_doc(requirement)}; " <>
              "this export is #{format}#{if grouped, do: " and grouped"}"
    end

    :ok
  end

  defp met?(requirement, format, grouped) do
    format in requirement["formats"] and Map.get(requirement, "grouped", grouped) == grouped
  end

  defp requirement_doc(requirement) do
    formats = "to #{requirement["formats"] |> Enum.map(&"`#{inspect(String.to_atom(&1))}`") |> or_join()}"

    case requirement["grouped"] do
      nil -> formats
      true -> formats <> " exports with `grouped: true`"
      false -> formats <> " exports that aren't grouped"
    end
  end

  defp or_join([one]), do: one
  defp or_join(list), do: Enum.join(Enum.drop(list, -1), ", ") <> " or " <> List.last(list)

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

    values
    |> Map.new(fn {key, value} ->
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
    |> put_defaults(schema)
  end

  defp object(values, _schema, what), do: invalid(values, "a keyword list", what)

  # The API fails on some properties left out, which the overlay marks
  # required and gives a default.
  defp put_defaults(object, schema) do
    for name <- schema["required"] || [],
        not Map.has_key?(object, name),
        %{"default" => default} = property <- [schema["properties"][name]],
        into: object,
        do: {name, value(default, property, name)}
  end

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

  # The API reads times in its own zone, so a DateTime is first moved there.
  defp value(%DateTime{} = datetime, %{"format" => "date-time"} = schema, what),
    do:
      datetime
      |> DateTime.shift_zone!(@server_time_zone, Tz.TimeZoneDatabase)
      |> DateTime.to_naive()
      |> value(schema, what)

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
