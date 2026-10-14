defmodule CastorEDC.Generator.Swagger2 do
  @moduledoc """
  Converts a Swagger 2.0 document into OpenAPI 3.1.

  The Castor EDC API publishes Swagger 2.0, while the generator reads
  OpenAPI 3.1. The converters on Hex are unmaintained, and the API's spec
  only uses a small part of Swagger 2.0, so this module converts exactly
  that part and raises on anything else:

    * `host`, `basePath` and `schemes` become `servers`
    * `definitions` become `components/schemas`, and every `$ref` follows;
      definition names that OpenAPI 3 doesn't allow (`Not Acceptable`) have
      their invalid characters replaced with `_`
    * `securityDefinitions` become `components/securitySchemes`, with the
      OAuth2 `application` flow as `clientCredentials`
    * `path`, `query` and `header` parameters keep their place, with their
      type moved into `schema`, and `collectionFormat` becomes `style` and
      `explode`
    * a `body` parameter becomes the `requestBody`, for each media type the
      operation consumes
    * `formData` parameters become a `requestBody` object schema, as
      `multipart/form-data` when there's a file and
      `application/x-www-form-urlencoded` otherwise
    * response schemas move under `content`, for each media type the
      operation produces
    * in schemas, `x-nullable: true` becomes a `"null"` type, and the `file`
      type becomes a binary string

  Extensions (`x-*`) are carried over unchanged.
  """

  @operation_methods ~w(get put post delete options head patch)
  @parameter_schema_keys ~w(type format items default maximum exclusiveMaximum minimum exclusiveMinimum
                            maxLength minLength pattern maxItems minItems uniqueItems enum multipleOf)

  @doc """
  Converts `document`, a decoded Swagger 2.0 document, into OpenAPI 3.1.
  """
  @spec convert!(map()) :: map()
  def convert!(%{"swagger" => "2.0"} = document) do
    names = schema_names(document["definitions"] || %{})
    defaults = %{consumes: document["consumes"] || [], produces: document["produces"] || []}

    %{
      "openapi" => "3.1.0",
      "info" => document["info"],
      "servers" => servers(document),
      "paths" =>
        Map.new(document["paths"] || %{}, fn {path, item} -> {path, path_item!(path, item, defaults, names)} end),
      "components" => %{
        "schemas" =>
          Map.new(document["definitions"] || %{}, fn {name, schema} -> {names[name], schema(schema, names)} end),
        "securitySchemes" =>
          Map.new(document["securityDefinitions"] || %{}, fn {name, scheme} -> {name, security_scheme!(scheme)} end)
      }
    }
    |> put_present("security", document["security"])
    |> put_present("tags", document["tags"])
    |> Map.merge(extensions(document))
  end

  def convert!(_document), do: raise(ArgumentError, "expected a Swagger 2.0 document")

  defp servers(%{"host" => host} = document) do
    base_path = String.trim_trailing(document["basePath"] || "", "/")

    for scheme <- document["schemes"] || ["https"] do
      %{"url" => "#{scheme}://#{host}#{base_path}"}
    end
  end

  defp servers(document), do: [%{"url" => String.trim_trailing(document["basePath"] || "/", "/")}]

  defp schema_names(definitions) do
    Map.new(definitions, fn {name, _schema} -> {name, String.replace(name, ~r/[^A-Za-z0-9._-]/, "_")} end)
  end

  defp path_item!(path, item, defaults, names) when is_map(item) do
    Map.new(item, fn
      {method, operation} when method in @operation_methods ->
        {method, operation!(path, method, operation, defaults, names)}

      {"parameters", parameters} ->
        {"parameters", Enum.map(parameters, &parameter!(&1, names))}

      {"x-" <> _rest = key, value} ->
        {key, value}

      {key, _value} ->
        raise ArgumentError, "unsupported key #{inspect(key)} in path item #{path}"
    end)
  end

  defp path_item!(path, item, _defaults, _names) do
    raise ArgumentError, "path item #{path} isn't an object: #{inspect(item)}"
  end

  defp operation!(path, method, operation, defaults, names) do
    consumes = operation["consumes"] || defaults.consumes
    produces = operation["produces"] || defaults.produces
    {body, parameters} = Enum.split_with(operation["parameters"] || [], &(&1["in"] in ["body", "formData"]))

    operation
    |> Map.drop(["consumes", "produces", "parameters", "responses", "schemes"])
    |> put_present("parameters", parameters != [] && Enum.map(parameters, &parameter!(&1, names)))
    |> put_present("requestBody", request_body!(path, method, body, consumes, names))
    |> Map.put(
      "responses",
      Map.new(operation["responses"] || %{}, fn {status, response} -> {status, response(response, produces, names)} end)
    )
  end

  defp parameter!(%{"in" => location} = parameter, names) when location in ["path", "query", "header"] do
    {schema, rest} = Map.split(parameter, @parameter_schema_keys)

    rest
    |> Map.delete("collectionFormat")
    |> Map.put("schema", schema(schema, names))
    |> Map.merge(style(parameter["collectionFormat"]))
  end

  defp parameter!(parameter, _names) do
    raise ArgumentError, "unsupported parameter #{inspect(parameter)}"
  end

  defp style(nil), do: %{}
  defp style("csv"), do: %{"style" => "form", "explode" => false}
  defp style("multi"), do: %{"style" => "form", "explode" => true}
  defp style("ssv"), do: %{"style" => "spaceDelimited", "explode" => false}
  defp style("pipes"), do: %{"style" => "pipeDelimited", "explode" => false}

  defp request_body!(_path, _method, [], _consumes, _names), do: nil

  defp request_body!(_path, _method, [%{"in" => "body"} = body], consumes, names) do
    schema = schema(body["schema"], names)

    %{"content" => Map.new(media_types(consumes, "application/json"), &{&1, %{"schema" => schema}})}
    |> put_present("description", body["description"])
    |> put_present("required", body["required"])
  end

  defp request_body!(path, method, parameters, _consumes, names) do
    if Enum.any?(parameters, &(&1["in"] == "body")) do
      raise ArgumentError, "#{String.upcase(method)} #{path} mixes a body parameter with form parameters"
    end

    media_type =
      if Enum.any?(parameters, &(&1["type"] == "file")),
        do: "multipart/form-data",
        else: "application/x-www-form-urlencoded"

    properties =
      Map.new(parameters, fn parameter ->
        {schema, _rest} = Map.split(parameter, @parameter_schema_keys)
        {parameter["name"], schema |> schema(names) |> put_present("description", parameter["description"])}
      end)

    required = for %{"required" => true, "name" => name} <- parameters, do: name

    schema =
      put_present(%{"type" => "object", "properties" => properties}, "required", required != [] && required)

    put_present(%{"content" => %{media_type => %{"schema" => schema}}}, "required", required != [] || nil)
  end

  defp response(response, produces, names) do
    {schema, rest} = Map.pop(response, "schema")

    if schema do
      content = Map.new(media_types(produces, "application/json"), &{&1, %{"schema" => schema(schema, names)}})
      Map.put(rest, "content", content)
    else
      rest
    end
  end

  defp media_types([], default), do: [default]
  defp media_types(types, _default), do: types

  defp schema(%{"$ref" => "#/definitions/" <> name} = schema, names) do
    Map.put(schema, "$ref", "#/components/schemas/" <> Map.get(names, name, name))
  end

  defp schema(schema, names) when is_map(schema) do
    schema
    |> Map.new(fn
      {key, value} when key in ["properties", "patternProperties"] ->
        {key, Map.new(value, fn {name, schema} -> {name, schema(schema, names)} end)}

      {key, value} when key in ["items", "additionalProperties", "not"] and is_map(value) ->
        {key, schema(value, names)}

      {key, value} when key in ["allOf", "anyOf", "oneOf"] ->
        {key, Enum.map(value, &schema(&1, names))}

      other ->
        other
    end)
    |> file_type()
    |> nullable()
  end

  defp file_type(%{"type" => "file"} = schema), do: Map.merge(schema, %{"type" => "string", "format" => "binary"})
  defp file_type(schema), do: schema

  defp nullable(%{"x-nullable" => true, "type" => type} = schema) when is_binary(type) do
    schema |> Map.delete("x-nullable") |> Map.put("type", [type, "null"])
  end

  defp nullable(schema), do: Map.delete(schema, "x-nullable")

  defp security_scheme!(%{"type" => "oauth2", "flow" => flow} = scheme) do
    flow_name =
      case flow do
        "application" -> "clientCredentials"
        "accessCode" -> "authorizationCode"
        "implicit" -> "implicit"
        "password" -> "password"
      end

    flow_object = Map.take(scheme, ["authorizationUrl", "tokenUrl", "scopes"])

    scheme
    |> Map.drop(["flow", "authorizationUrl", "tokenUrl", "scopes"])
    |> Map.put("flows", %{flow_name => flow_object})
  end

  defp security_scheme!(%{"type" => "apiKey"} = scheme), do: scheme

  defp security_scheme!(%{"type" => "basic"} = scheme),
    do: Map.merge(Map.delete(scheme, "type"), %{"type" => "http", "scheme" => "basic"})

  defp extensions(map), do: Map.filter(map, fn {key, _value} -> String.starts_with?(key, "x-") end)

  defp put_present(map, _key, value) when value in [nil, false], do: map
  defp put_present(map, key, value), do: Map.put(map, key, value)
end
