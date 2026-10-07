defmodule CastorEDC.GeneratedOperationsTest do
  @moduledoc """
  Every generated operation, with its `!` and `stream_` variants, sends the
  request its spec describes and returns the result its typespec promises.

  The fixture contract test checks real responses for the operations that
  have fixtures; this covers every operation, with minimal responses.
  """

  use CastorEDC.Case, async: true

  alias CastorEDC.Generator
  alias CastorEDC.Generator.Renderer
  alias CastorEDC.Page

  @spec_path "priv/openapi/castor_edc.json"
  @external_resource @spec_path

  @api Generator.load!(@spec_path)

  for group <- @api.groups, operation <- group.operations do
    test "#{inspect(group.module)}.#{operation.name}" do
      check(unquote(group.module), unquote(Macro.escape(operation)))
    end
  end

  for model <- @api.models do
    test "#{inspect(model.module)} decodes an empty object" do
      assert %{__struct__: unquote(model.module), extra: %{}} = unquote(model.module).new(%{})
    end
  end

  defp check(module, operation) do
    values = Enum.with_index(operation.path_params, fn _param, index -> "value-#{index}" end)
    arguments = values ++ if(operation.body, do: [%{"a" => 1}], else: [])
    name = String.to_atom(operation.name)
    client = client(&respond(operation, &1))

    assert {:ok, result} = apply(module, name, [client | arguments] ++ [[]])
    assert_result(operation, result)
    assert_request(operation, values)

    assert apply(module, :"#{name}!", [client | arguments] ++ [[]]) == result
    assert_request(operation, values)

    if operation.paged do
      stream = :"#{Renderer.stream_name(operation)}"
      assert module |> apply(stream, [client | arguments] ++ [[]]) |> Enum.to_list() == decode([%{}], operation)
      assert_request(operation, values)
    end
  end

  # One record for collections, an empty object for single resources, and
  # bytes for downloads.
  defp respond(operation, _request) do
    cond do
      operation.accept == "*/*" ->
        Req.Response.new(status: 200, body: "PK", headers: %{"content-type" => ["application/zip"]})

      operation.items ->
        operation.items
        |> String.split(".")
        |> Enum.reverse()
        |> Enum.reduce([%{}], fn key, inner -> %{key => inner} end)
        |> Map.merge(%{"page" => 1, "page_count" => 1, "page_size" => 1, "total_items" => 1})
        |> json()

      true ->
        json(%{})
    end
  end

  defp assert_result(operation, result) do
    cond do
      operation.accept == "*/*" ->
        assert result == "PK"

      operation.items ->
        assert %Page{entries: entries, page: 1, page_count: 1} = result
        assert entries == decode([%{}], operation)

      operation.decode ->
        assert result == operation.decode.new(%{})

      true ->
        assert result == %{}
    end
  end

  defp decode(records, %{decode: nil}), do: records
  defp decode(records, %{decode: module}), do: Enum.map(records, &module.new/1)

  defp assert_request(operation, values) do
    request = assert_requested()
    path = Enum.reduce(Enum.zip(operation.path_params, values), operation.path, &replace/2)

    assert request.method == operation.method
    assert request.url.path == path
    if operation.body, do: assert(request.body |> IO.iodata_to_binary() |> JSON.decode!() == %{"a" => 1})
  end

  defp replace({param, value}, path), do: String.replace(path, "{#{param.wire}}", value)
end
