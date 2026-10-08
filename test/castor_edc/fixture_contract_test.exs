defmodule CastorEDC.FixtureContractTest do
  @moduledoc """
  Every recorded response in test/fixtures decodes through the generated
  client without leaving anything in a struct's `extra`, and the generated
  function sends the request the fixture was recorded with.

  A failure means the fixtures, the corrected spec and the generated
  structs have drifted apart: the API sends a field the spec doesn't
  describe (describe it in priv/openapi/overlay.yaml), or a fixture
  records a response the API no longer sends (record it again).
  """

  use CastorEDC.Case, async: true

  alias CastorEDC.Generator

  @spec_path "priv/openapi/castor_edc.json"
  @external_resource @spec_path

  @operations (for group <- Generator.load!(@spec_path).groups, operation <- group.operations, into: %{} do
                 {operation.name, {group.module, operation}}
               end)

  for meta_path <- Path.wildcard("test/fixtures/*.meta.json") do
    @external_resource meta_path
    meta = meta_path |> File.read!() |> JSON.decode!()
    name = Path.basename(meta_path, ".meta.json")

    test "#{name} decodes completely" do
      check(unquote(name), unquote(Macro.escape(meta)))
    end
  end

  defp check(name, %{"operation" => operation_name} = meta) do
    assert {module, operation} = Map.fetch!(@operations, operation_name),
           "#{name} records #{operation_name}, which the spec doesn't have"

    body = fixture(name)
    client = client(json(body, status: meta["status"]))

    arguments =
      [client] ++
        path_values(operation, meta["path"]) ++
        if(operation.body, do: [%{}], else: []) ++ [[]]

    assert {:ok, result} = apply(module, String.to_atom(operation.name), arguments)

    request = assert_requested()
    assert request.method == meta["method"] |> String.downcase() |> String.to_atom()
    assert request.url.path == URI.decode(meta["path"])

    undescribed = result |> undescribed([]) |> Enum.uniq()

    assert undescribed == [],
           "keys the spec doesn't describe: #{inspect(undescribed)}; describe them or record #{name} again"
  end

  # The values of an operation's path parameters, in argument order, taken
  # from the path the fixture was recorded with.
  defp path_values(operation, path) do
    pattern = Regex.replace(~r/\\\{[^}]+\\\}/, Regex.escape(operation.path), "([^/]+)")
    [_path | values] = Regex.run(~r/^#{pattern}$/, path) || flunk("#{path} doesn't match #{operation.path}")
    Enum.map(values, &URI.decode/1)
  end

  defp undescribed(%CastorEDC.Page{entries: entries}, acc), do: undescribed(entries, acc)
  defp undescribed(list, acc) when is_list(list), do: Enum.reduce(list, acc, &undescribed/2)

  defp undescribed(%{__struct__: module, extra: extra} = struct, acc) do
    acc = if extra == %{}, do: acc, else: [{module, extra |> Map.keys() |> Enum.sort()} | acc]
    struct |> Map.from_struct() |> Map.delete(:extra) |> Map.values() |> undescribed(acc)
  end

  defp undescribed(_value, acc), do: acc
end
