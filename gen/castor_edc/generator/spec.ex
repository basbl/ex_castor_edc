defmodule CastorEDC.Generator.Spec do
  @moduledoc """
  Reads the corrected API spec (`priv/openapi/castor_edc.json`, OpenAPI
  3.1) into the structs the renderers work from.

  `parse/1` resolves every `$ref`, so nothing after it sees one. It
  produces:

    * `groups` - one per `x-castor-module`, with its operations, sorted by
      name, and the description the spec's top-level `x-castor-modules`
      gives it
    * `models` - one per schema a response can reach, directly or nested,
      except schemas the client casts rather than decodes (those with an
      `x-castor-type`, such as `PhpDateTime`)
  """

  alias CastorEDC.Generator.Naming

  defstruct [:base_path, groups: [], models: []]

  @type t :: %__MODULE__{base_path: String.t(), groups: [__MODULE__.Group.t()], models: [__MODULE__.Model.t()]}

  defmodule Group do
    @moduledoc "An operation group, generated into one module."
    defstruct [:name, :module, :description, operations: []]
    @type t :: %__MODULE__{}
  end

  defmodule Operation do
    @moduledoc "One API operation, generated into a function (and a `!` and `stream_` variant)."
    defstruct [
      :name,
      :method,
      :path,
      :summary,
      :description,
      :doc_url,
      :body,
      :decode,
      :items,
      :max_page_size,
      :accept,
      path_params: [],
      query_params: [],
      paged: false,
      not_found_is_empty: nil,
      partial_success: false,
      fill_items: %{}
    ]

    @type t :: %__MODULE__{}
  end

  defmodule Param do
    @moduledoc "A path or query parameter of an operation."
    defstruct [:name, :wire, :description, :type, :default, :maximum, encoding: :plain, required: false]
    @type t :: %__MODULE__{}
  end

  defmodule Body do
    @moduledoc "The request body of an operation."
    defstruct [:description, :model, fields: [], required: false]
    @type t :: %__MODULE__{}
  end

  defmodule Model do
    @moduledoc "A schema, generated into a struct under `CastorEDC.Model`."
    defstruct [:name, :module, :description, fields: []]
    @type t :: %__MODULE__{}
  end

  defmodule Field do
    @moduledoc "A field of a model."
    # `wires` lists the keys the value can arrive under; the first present
    # one wins. `decode` is `{:one, module}`, `{:list, module}`,
    # `{:cast, type}` or `:raw`.
    defstruct [:name, :description, :type, decode: :raw, wires: [], required: false]
    @type t :: %__MODULE__{}
  end

  @methods ~w(get post put patch delete)

  @doc """
  Parses a decoded OpenAPI 3.1 document.
  """
  @spec parse(map()) :: t()
  def parse(document) do
    schemas = get_in(document, ["components", "schemas"]) || %{}
    base_path = base_path(document)

    operations =
      for {path, item} <- document["paths"] || %{},
          {method, operation} <- item,
          method in @methods do
        operation(document, base_path, path, method, operation)
      end

    groups =
      operations
      |> Enum.group_by(fn {group, _operation} -> group end, fn {_group, operation} -> operation end)
      |> Enum.map(fn {name, operations} ->
        %Group{
          name: name,
          module: Naming.group_module(name),
          description: get_in(document, ["x-castor-modules", name]),
          operations: Enum.sort_by(operations, & &1.name)
        }
      end)
      |> Enum.sort_by(& &1.name)

    models = models(document, schemas)
    known = MapSet.new(models, & &1.module)
    names = Map.new(Map.keys(schemas), &{Naming.model_module(&1), &1})

    groups =
      Enum.map(groups, fn group ->
        %{group | operations: Enum.map(group.operations, &inline_body(&1, document, known, names))}
      end)

    %__MODULE__{base_path: base_path, groups: groups, models: models}
  end

  # A request body can refer to schemas no response reaches, which get no
  # struct: their fields are listed in the body's docs instead.
  defp inline_body(%Operation{body: %Body{} = body} = operation, document, known, names) do
    %{operation | body: %{body | fields: Enum.map(body.fields, &inline_field(&1, document, known, names, 3))}}
  end

  defp inline_body(operation, _document, _known, _names), do: operation

  defp inline_field(field, document, known, names, depth),
    do: %{field | type: inline_type(field.type, document, known, names, depth)}

  defp inline_type({:list, item}, document, known, names, depth),
    do: {:list, inline_type(item, document, known, names, depth)}

  defp inline_type({:model, module} = type, document, known, names, depth) do
    with false <- MapSet.member?(known, module),
         true <- depth > 0,
         %{} = name <- names[module] && %{name: names[module]} do
      fields =
        document
        |> fields(%{"$ref" => "#/components/schemas/" <> name.name})
        |> Enum.map(&inline_field(&1, document, known, names, depth - 1))

      {:fields, fields}
    else
      _known_or_too_deep -> type
    end
  end

  defp inline_type(type, _document, _known, _names, _depth), do: type

  defp base_path(document) do
    case document["servers"] do
      [%{"url" => url} | _rest] -> URI.parse(url).path || ""
      _none -> ""
    end
  end

  defp operation(document, base_path, path, method, operation) do
    name = operation["operationId"] || raise ArgumentError, "#{String.upcase(method)} #{path} has no operationId"
    group = operation["x-castor-module"] || raise ArgumentError, "#{name} has no x-castor-module"
    parameters = Enum.map(operation["parameters"] || [], &deref(document, &1))
    query = for %{"in" => "query"} = parameter <- parameters, do: param(document, parameter)

    {success, response} = success_response(operation)
    {content_type, schema} = response_content(response)

    {group,
     %Operation{
       name: name,
       method: String.to_atom(method),
       path: base_path <> path,
       summary: operation["summary"],
       description: operation["description"],
       doc_url: doc_url(operation, path, method),
       path_params: path_params(document, path, parameters),
       query_params: query,
       paged: Enum.any?(query, &(&1.wire == "page")),
       max_page_size: operation["x-castor-max-page-size"],
       body: body(document, operation["requestBody"]),
       items: operation["x-castor-items"],
       decode: decode(document, schema, operation["x-castor-items"], success),
       accept: accept(content_type),
       not_found_is_empty: operation["x-castor-not-found-is-empty"],
       partial_success: operation["x-castor-partial-success"] == true,
       fill_items: fill_items(name, path, operation["x-castor-fill-items"])
     }}
  end

  # Keys of the body's list items that the client fills from a path
  # parameter: `%{"data" => %{"instance_id" => "repeating_data_instance_id"}}`.
  defp fill_items(_name, _path, nil), do: %{}

  defp fill_items(name, path, fill_items) do
    for {_list, keys} <- fill_items, {_key, param} <- keys, not String.contains?(path, "{#{param}}") do
      raise ArgumentError, "#{name} fills items from {#{param}}, which isn't in its path #{path}"
    end

    fill_items
  end

  # Path parameters in the order the path names them, which is the order
  # of the generated function's arguments.
  defp path_params(document, path, parameters) do
    by_name = for %{"in" => "path", "name" => name} = parameter <- parameters, into: %{}, do: {name, parameter}

    for [_match, name] <- Regex.scan(~r/\{([^}]+)\}/, path) do
      parameter = Map.get(by_name, name, %{"name" => name, "in" => "path", "schema" => %{"type" => "string"}})
      %{param(document, parameter) | required: true}
    end
  end

  defp param(document, parameter) do
    schema = deref(document, parameter["schema"] || %{})

    %Param{
      name: parameter["x-castor-name"] || Naming.snake(parameter["name"]),
      wire: parameter["name"],
      description: parameter["description"],
      type: type_doc(document, schema),
      default: schema["default"],
      maximum: schema["maximum"],
      encoding: encoding(schema, parameter),
      required: parameter["required"] == true
    }
  end

  # How a query parameter's value goes on the wire: as it is, a boolean as 1
  # or 0 (`x-castor-wire: integer`), a list joined
  # with commas (`explode: false`), a list as one key per value (OpenAPI's
  # default for arrays), or a map as `name[key]=value` (`deepObject`).
  defp encoding(%{"type" => "boolean"}, %{"x-castor-wire" => "integer"}), do: :flag
  defp encoding(%{"type" => "array"}, %{"explode" => false}), do: :csv
  defp encoding(%{"type" => "array"}, _parameter), do: :repeat
  defp encoding(%{"type" => "object"}, %{"style" => "deepObject"}), do: :map
  defp encoding(_schema, _parameter), do: :plain

  defp success_response(operation) do
    responses = operation["responses"] || %{}

    case responses |> Enum.filter(fn {status, _response} -> String.starts_with?(status, "2") end) |> Enum.sort() do
      [{status, response} | _rest] -> {status, response}
      [] -> {nil, %{}}
    end
  end

  defp response_content(%{"content" => content}) when map_size(content) > 0 do
    type =
      Enum.find(["application/hal+json", "application/json"], &Map.has_key?(content, &1)) ||
        content |> Map.keys() |> hd()

    {type, content[type]["schema"]}
  end

  defp response_content(_response), do: {nil, nil}

  defp accept("application/hal+json"), do: nil
  defp accept("application/json"), do: "application/json"
  defp accept(nil), do: nil
  defp accept(_binary), do: "*/*"

  defp decode(_document, nil, _items, _status), do: nil

  defp decode(document, schema, nil, _status) do
    case schema do
      %{"$ref" => ref} -> if model_ref?(document, ref), do: ref |> ref_name() |> Naming.model_module()
      _inline -> nil
    end
  end

  defp decode(document, schema, items, _status) do
    case get_items(document, schema, items) do
      %{"$ref" => ref} -> if model_ref?(document, ref), do: ref |> ref_name() |> Naming.model_module()
      _inline -> nil
    end
  end

  # Follows the dot-separated path of x-castor-items through the response
  # schema to the schema of one record.
  defp get_items(document, schema, path) do
    path
    |> String.split(".")
    |> Enum.reduce(schema, fn key, schema ->
      schema = deref(document, schema || %{})
      get_in(schema, ["properties", key])
    end)
    |> case do
      %{"items" => items} -> items
      _other -> nil
    end
  end

  defp body(_document, nil), do: nil

  defp body(document, request_body) do
    {_type, media} = request_body["content"] |> Enum.sort() |> hd()
    schema = media["schema"] || %{}
    resolved = deref(document, schema)

    %Body{
      description: request_body["description"],
      required: request_body["required"] == true,
      model:
        case schema do
          %{"$ref" => ref} -> ref_name(ref)
          _inline -> nil
        end,
      fields: fields(document, resolved)
    }
  end

  # Models: every schema a successful response can reach. Error bodies are
  # read by CastorEDC.Error, and HAL links are dropped.

  defp models(document, schemas) do
    document["paths"]
    |> Map.values()
    |> Enum.flat_map(&Map.values/1)
    |> Enum.filter(&is_map/1)
    |> Enum.map(&(&1 |> success_response() |> elem(1)))
    |> Enum.reduce(MapSet.new(), &collect_refs(&1, document, &2))
    |> Enum.filter(&model_ref?(document, "#/components/schemas/" <> &1))
    |> Enum.sort()
    |> Enum.map(fn name -> model(document, name, schemas[name]) end)
  end

  defp collect_refs(%{"$ref" => "#/components/schemas/" <> name}, document, seen) do
    if MapSet.member?(seen, name) do
      seen
    else
      collect_refs(get_in(document, ["components", "schemas", name]), document, MapSet.put(seen, name))
    end
  end

  defp collect_refs(map, document, seen) when is_map(map) do
    map |> Map.delete("_links") |> Map.values() |> Enum.reduce(seen, &collect_refs(&1, document, &2))
  end

  defp collect_refs(list, document, seen) when is_list(list),
    do: Enum.reduce(list, seen, &collect_refs(&1, document, &2))

  defp collect_refs(_scalar, _document, seen), do: seen

  defp model(document, name, schema) do
    %Model{
      name: name,
      module: Naming.model_module(name),
      description: schema["description"],
      fields: fields(document, schema)
    }
  end

  # The fields of an object schema: its properties, minus the HAL links,
  # plus the embedded objects the schema describes. Properties renamed to
  # the same field (field_value and value) become one field.
  defp fields(document, schema) do
    schema = deref(document, schema)
    required = schema["required"] || []
    properties = Map.drop(schema["properties"] || %{}, ["_links", "_embedded"])
    embedded = embedded_properties(document, schema)

    (Enum.sort(properties) ++ Enum.sort(embedded))
    |> Enum.map(fn {wire, property} -> field(document, wire, property, wire in required) end)
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {_name, [first | _rest] = same} ->
      %{first | wires: Enum.flat_map(same, & &1.wires), required: Enum.any?(same, & &1.required)}
    end)
    |> Enum.sort_by(&{not &1.required, &1.name})
  end

  defp embedded_properties(document, schema) do
    case deref(document, get_in(schema, ["properties", "_embedded"]) || %{}) do
      %{"properties" => properties} when is_map(properties) ->
        Map.new(properties, fn {key, property} -> {"_embedded." <> key, property} end)

      _undescribed ->
        %{}
    end
  end

  defp field(document, wire, property, required) do
    key = wire |> String.split(".") |> List.last()

    %Field{
      name: property["x-castor-rename"] || Naming.snake(key),
      wires: [wire],
      description: property["description"] || deref(document, property)["description"],
      type: type_doc(document, property),
      decode: field_decode(document, property),
      required: required
    }
  end

  defp field_decode(document, property) do
    case non_null(property) do
      %{"x-castor-type" => type} ->
        {:cast, String.to_atom(type)}

      %{"$ref" => ref} ->
        cond do
          type = cast_type(document, ref) -> {:cast, type}
          model_ref?(document, ref) -> {:one, ref |> ref_name() |> Naming.model_module()}
          true -> :raw
        end

      %{"type" => "array", "items" => %{"$ref" => ref}} ->
        if model_ref?(document, ref), do: {:list, ref |> ref_name() |> Naming.model_module()}, else: :raw

      _other ->
        :raw
    end
  end

  # Types, for docs and typespecs.

  @doc false
  def type_doc(document, schema) do
    case non_null(schema) do
      %{"x-castor-type" => "naive_datetime"} -> {:naive_datetime, nil}
      %{"x-castor-type" => "datetime"} -> {:datetime, nil}
      %{"$ref" => ref} -> ref_type(document, ref)
      %{"type" => "array"} = array -> {:list, type_doc(document, array["items"] || %{})}
      %{"type" => type} when is_binary(type) -> {String.to_atom(type), schema["enum"]}
      _untyped -> {:any, nil}
    end
  end

  defp ref_type(document, ref) do
    cond do
      type = cast_type(document, ref) -> {type, nil}
      model_ref?(document, ref) -> {:model, ref |> ref_name() |> Naming.model_module()}
      true -> type_doc(document, deref(document, %{"$ref" => ref}))
    end
  end

  # A referenced schema becomes a model when it's an object, and isn't
  # cast to an Elixir type instead.
  # A nullable schema has `"type": [type, "null"]` in OpenAPI 3.1; every
  # field can be nil anyway, so only the type matters.
  defp non_null(%{"type" => types} = schema) when is_list(types) do
    case List.delete(types, "null") do
      [type] -> %{schema | "type" => type}
      _several -> schema
    end
  end

  defp non_null(schema), do: schema

  defp model_ref?(document, ref) do
    schema = deref(document, %{"$ref" => ref})
    is_nil(schema["x-castor-type"]) and (schema["type"] == "object" or Map.has_key?(schema, "properties"))
  end

  defp cast_type(document, ref) do
    case deref(document, %{"$ref" => ref}) do
      %{"x-castor-type" => type} -> String.to_atom(type)
      _other -> nil
    end
  end

  defp doc_url(operation, path, method) do
    tag = operation |> Map.get("tags", []) |> List.first("default")
    slug = String.replace(method <> path, ~r/[^A-Za-z0-9]/, "_")
    "https://data.castoredc.com/api#/#{tag}/#{slug}"
  end

  @doc false
  @spec deref(map(), map()) :: map()
  def deref(document, %{"$ref" => "#/" <> pointer}) do
    target = get_in(document, String.split(pointer, "/")) || raise ArgumentError, "dangling $ref #/#{pointer}"
    deref(document, target)
  end

  def deref(_document, schema), do: schema

  defp ref_name("#/components/schemas/" <> name), do: name
end
