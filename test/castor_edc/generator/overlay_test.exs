defmodule CastorEDC.Generator.OverlayTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Overlay

  @document %{
    "paths" => %{
      "/study" => %{"get" => %{"summary" => "List studies", "tags" => ["study"]}},
      "/record" => %{"get" => %{"deprecated" => true}, "post" => %{"deprecated" => true}}
    },
    "tags" => ["a", "b", "c"]
  }

  defp overlay(actions), do: %{"overlay" => "1.0.0", "actions" => actions}

  test "removes every node a target selects" do
    result = Overlay.apply!(@document, overlay([%{"target" => "$.paths.*[?@.deprecated == true]", "remove" => true}]))

    assert result["paths"]["/record"] == %{}
    assert result["paths"]["/study"] == @document["paths"]["/study"]
  end

  test "removes several list items without shifting the ones still to remove" do
    result = Overlay.apply!(@document, overlay([%{"target" => "$.tags[?@ != 'b']", "remove" => true}]))

    assert result["tags"] == ["b"]
  end

  test "deep-merges an update into the objects it selects" do
    action = %{
      "target" => "$.paths['/study'].get",
      "update" => %{"operationId" => "list_studies", "x-castor" => %{"module" => "Studies"}}
    }

    result =
      Overlay.apply!(@document, overlay([action, %{action | "update" => %{"x-castor" => %{"items" => "study"}}}]))

    assert result["paths"]["/study"]["get"] == %{
             "summary" => "List studies",
             "tags" => ["study"],
             "operationId" => "list_studies",
             "x-castor" => %{"module" => "Studies", "items" => "study"}
           }
  end

  test "an update replaces scalars and lists rather than merging them" do
    action = %{"target" => "$.paths['/study'].get", "update" => %{"summary" => "Studies", "tags" => ["studies"]}}

    assert %{"summary" => "Studies", "tags" => ["studies"]} =
             Overlay.apply!(@document, overlay([action]))["paths"]["/study"]["get"]
  end

  test "appends an update to an array it selects" do
    result = Overlay.apply!(@document, overlay([%{"target" => "$.tags", "update" => "d"}]))

    assert result["tags"] == ["a", "b", "c", "d"]
  end

  test "applies actions in order" do
    actions = [
      %{"target" => "$.paths['/record']", "remove" => true},
      %{"target" => "$.paths.*", "update" => %{"x-seen" => true}}
    ]

    assert Overlay.apply!(@document, overlay(actions))["paths"] == %{
             "/study" => Map.put(@document["paths"]["/study"], "x-seen", true)
           }
  end

  test "raises when a target selects nothing, quoting the description" do
    action = %{"target" => "$.paths['/gone'].get", "description" => "Name the gone operation.", "remove" => true}

    error = assert_raise ArgumentError, fn -> Overlay.apply!(@document, overlay([action])) end
    assert error.message =~ "$.paths['/gone'].get selects nothing"
    assert error.message =~ "Name the gone operation."
  end

  test "raises on malformed actions" do
    assert_raise ArgumentError, fn -> Overlay.apply!(@document, overlay([%{"target" => "$.tags"}])) end
    assert_raise ArgumentError, fn -> Overlay.apply!(@document, overlay([%{"remove" => true}])) end
    assert_raise ArgumentError, fn -> Overlay.apply!(@document, %{"overlay" => "1.0.0"}) end

    assert_raise ArgumentError, fn ->
      Overlay.apply!(@document, overlay([%{"target" => "$.paths['/study'].get.summary", "update" => %{"a" => 1}}]))
    end
  end
end
