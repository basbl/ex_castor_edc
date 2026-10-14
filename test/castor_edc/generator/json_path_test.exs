defmodule CastorEDC.Generator.JSONPathTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.JSONPath

  @document %{
    "paths" => %{
      "/study" => %{
        "get" => %{"tags" => ["study"], "deprecated" => false},
        "post" => %{"tags" => ["study", "beta"]}
      },
      "/record" => %{
        "get" => %{"tags" => ["record"], "deprecated" => true, "x-count" => 3}
      }
    },
    "list" => ["a", "b", "c"]
  }

  defp paths(query), do: @document |> JSONPath.select(query) |> Enum.map(&elem(&1, 0))

  test "selects children by name, in either notation" do
    assert paths("$.paths['/study'].get") == [["paths", "/study", "get"]]
    assert paths(~s|$["paths"]["/record"].get.tags|) == [["paths", "/record", "get", "tags"]]
  end

  test "selects list items by index, counting negative indexes from the end" do
    assert JSONPath.select(@document, "$.list[0]") == [{["list", 0], "a"}]
    assert JSONPath.select(@document, "$.list[-1]") == [{["list", 2], "c"}]
    assert JSONPath.select(@document, "$.list[3]") == []
  end

  test "wildcards select every child, map keys in sorted order" do
    assert paths("$.paths.*") == [["paths", "/record"], ["paths", "/study"]]
    assert paths("$.list[*]") == [["list", 0], ["list", 1], ["list", 2]]
  end

  test "a missing child selects nothing" do
    assert JSONPath.select(@document, "$.paths['/nope'].get") == []
    assert JSONPath.select(@document, "$.list.name") == []
  end

  test "filters compare against literals" do
    assert paths("$.paths.*[?@.deprecated == true]") == [["paths", "/record", "get"]]
    assert paths("$.paths.*[?@.deprecated != true]") == [["paths", "/study", "get"], ["paths", "/study", "post"]]
    assert paths("$.paths.*[?@['x-count'] >= 3]") == [["paths", "/record", "get"]]
    assert paths("$.paths.*[?@['x-count'] < 3]") == []
  end

  test "filters test for existence, including with nested filters" do
    assert paths("$.paths.*[?@.deprecated]") == [["paths", "/record", "get"], ["paths", "/study", "get"]]
    assert paths("$.paths.*[?@.tags[?@ == 'beta']]") == [["paths", "/study", "post"]]
  end

  test "filters combine with &&, || and !, and respect parentheses" do
    assert paths("$.paths.*[?@.deprecated == false && @.tags[?@ == 'study']]") == [["paths", "/study", "get"]]

    assert paths("$.paths.*[?@.deprecated == true || @.tags[?@ == 'beta']]") == [
             ["paths", "/record", "get"],
             ["paths", "/study", "post"]
           ]

    assert paths("$.paths.*[?!@.deprecated]") == [["paths", "/study", "post"]]
    assert paths("$.paths.*[?!(@.deprecated == true || @.deprecated == false)]") == [["paths", "/study", "post"]]
  end

  test "filters can refer to the root" do
    assert paths("$.list[?@ == $.list[1]]") == [["list", 1]]
  end

  test "rejects invalid and unsupported queries" do
    for query <- ["paths", "$..paths", "$.list[0:2]", "$.paths[?@.a ==]", "$['open"] do
      assert_raise ArgumentError, fn -> JSONPath.parse!(query) end
    end
  end
end
