defmodule CastorEDC.Client do
  @moduledoc """
  Runs the operations of the API.

  The generated modules (`CastorEDC.Participants` and the rest) describe
  each operation, from its path to the struct its response decodes into,
  and hand that description to `request/2`. This module does everything
  that's the same for all of them: building the URL, sending the
  caller's options under the names the API knows them by, unwrapping
  collections into `CastorEDC.Page`s, decoding responses into structs, and
  turning failures into `CastorEDC.Error`s.

  Build the client these functions take with `CastorEDC.new/1`.
  """

  alias CastorEDC.Error
  alias CastorEDC.Page

  @type operation :: keyword()

  @doc """
  Runs one operation.

  `client` is a client from `CastorEDC.new/1`, or the options to build one
  with. `operation` describes the operation:

    * `:method` - the HTTP method
    * `:path` - the path template, such as `"/api/study/{study_id}/site"`
    * `:path_params` - the values of the template's placeholders, as a map
    * `:query` - the caller's options
    * `:query_names` - each option the operation takes, mapped to its name
      on the wire; options it doesn't take are passed to `Req`
    * `:list_params` - options that are lists, sent comma-separated
    * `:body` - the request body, sent as JSON
    * `:accept` - the `Accept` header, `application/hal+json` by default
    * `:items` - where a collection's records sit in the response body, as
      a dot-separated path (`"_embedded.participants"`); the result is then a
      `CastorEDC.Page`
    * `:max_page_size` - the largest `page_size` the API accepts; larger
      ones are lowered to it
    * `:not_found_is_empty` - a 404 means an empty collection
    * `:decode` - the struct module the response, or each record, decodes
      into; without it the body is returned as it arrived
    * `:partial_success` - the response lists what was saved under `saved`
      (`success` on the wire) and what wasn't under `failed`; `request!/2`
      raises when anything failed
  """
  @spec request(CastorEDC.client(), operation()) :: {:ok, term()} | {:error, Error.t()}
  def request(client, operation) do
    {query, req_options} = split_options(operation[:query] || [], operation[:query_names] || %{})

    options =
      [
        method: Keyword.fetch!(operation, :method),
        url: interpolate(Keyword.fetch!(operation, :path), operation[:path_params] || %{}),
        params: query |> join_lists(operation[:list_params] || []) |> clamp_page_size(operation[:max_page_size]),
        headers: [accept: operation[:accept] || "application/hal+json"]
      ] ++ body(operation) ++ req_options

    client
    |> to_request()
    |> Req.Request.put_private(:castor_edc_route, Keyword.fetch!(operation, :path))
    |> Req.request(options)
    |> handle(operation)
  end

  @doc """
  Runs one operation, returning its result or raising `CastorEDC.Error`.
  """
  @spec request!(CastorEDC.client(), operation()) :: term()
  def request!(client, operation) do
    case request(client, operation) do
      {:ok, result} -> check_partial_success!(result, operation)
      {:error, error} -> raise error
    end
  end

  # A write that saved some values and not others still answers 201. The
  # `!` variant shouldn't return as if everything was saved.
  defp check_partial_success!(result, operation) do
    failed = if operation[:partial_success], do: failures(result), else: []

    if failed == [] do
      result
    else
      raise %Error{
        message: "#{length(failed)} value(s) were not saved: " <> Enum.map_join(failed, "; ", &failure_message/1),
        code: :not_saved,
        details: Enum.map(failed, &%{code: get(&1, :code), message: get(&1, :message), field: get(&1, :field_id)}),
        body: result
      }
    end
  end

  defp failures(%{failed: failed}) when is_list(failed), do: failed
  defp failures(%{"failed" => failed}) when is_list(failed), do: failed
  defp failures(_result), do: []

  defp failure_message(failure), do: "#{get(failure, :field_id)}: #{get(failure, :message)}"

  defp get(map, key) when is_map(map), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))

  defp to_request(%Req.Request{} = request), do: request
  defp to_request(options) when is_list(options), do: CastorEDC.new(options)

  # The caller's keyword list holds the operation's own parameters, which
  # the API knows by the names in `query_names`, and options for Req.
  defp split_options(options, query_names) do
    {query, req_options} = Enum.split_with(options, fn {name, _value} -> Map.has_key?(query_names, name) end)

    query = for {name, value} <- query, not is_nil(value), do: {name, value}

    {Enum.map(query, fn {name, value} -> {name, Map.fetch!(query_names, name), value} end), req_options}
  end

  defp join_lists(query, list_params) do
    Enum.map(query, fn {name, wire, value} ->
      if name in list_params and is_list(value),
        do: {name, wire, Enum.map_join(value, ",", &to_string/1)},
        else: {name, wire, value}
    end)
  end

  defp clamp_page_size(query, max) do
    Enum.map(query, fn
      {:page_size, wire, size} when is_integer(max) and is_integer(size) and size > max -> {wire, max}
      {_name, wire, value} -> {wire, value}
    end)
  end

  # A path parameter is one segment, so a slash inside a value has to stay
  # encoded rather than split the path.
  defp interpolate(path, params) do
    Enum.reduce(params, path, fn {name, value}, path ->
      String.replace(path, "{#{name}}", value |> to_string() |> URI.encode(&URI.char_unreserved?/1))
    end)
  end

  defp body(operation) do
    case Keyword.fetch(operation, :body) do
      {:ok, body} -> [json: body]
      :error -> []
    end
  end

  defp handle({:ok, %Req.Response{status: status, body: body}}, operation) when status in 200..299 do
    {:ok, decode(body, operation)}
  end

  defp handle({:ok, %Req.Response{status: 404} = response}, operation) do
    if operation[:not_found_is_empty], do: {:ok, Page.empty()}, else: {:error, Error.from_response(response)}
  end

  defp handle({:ok, %Req.Response{} = response}, _operation), do: {:error, Error.from_response(response)}
  defp handle({:error, exception}, _operation), do: {:error, Error.from_exception(exception)}

  defp decode(body, _operation) when body in [nil, ""], do: nil

  defp decode(body, operation) when is_map(body) do
    case operation[:items] do
      nil ->
        decode_one(body, operation[:decode])

      path ->
        entries = body |> get_path(path) |> List.wrap() |> Enum.map(&decode_one(&1, operation[:decode]))
        Page.from_body(body, entries)
    end
  end

  defp decode(body, _operation), do: body

  defp decode_one(data, module) when is_atom(module) and not is_nil(module) and is_map(data), do: module.new(data)
  defp decode_one(data, _module), do: data

  defp get_path(body, path) do
    Enum.reduce_while(String.split(path, "."), body, fn key, data ->
      case data do
        %{^key => value} -> {:cont, value}
        _missing -> {:halt, []}
      end
    end)
  end
end
