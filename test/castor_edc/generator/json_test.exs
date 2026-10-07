defmodule CastorEDC.Generator.JSONTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.JSON

  test "sorts keys and indents nested values" do
    assert JSON.encode!(%{"b" => [1, %{"d" => true, "c" => nil}], "a" => "x"}) == """
           {
             "a": "x",
             "b": [
               1,
               {
                 "c": null,
                 "d": true
               }
             ]
           }
           """
  end

  test "writes empty containers inline" do
    assert JSON.encode!(%{"a" => %{}, "b" => []}) == """
           {
             "a": {},
             "b": []
           }
           """
  end

  test "escapes strings" do
    assert JSON.encode!(["quote \" and newline \n"]) == ~s([\n  "quote \\" and newline \\n"\n]\n)
  end

  test "round-trips through the built-in decoder" do
    value = %{"paths" => %{"/a" => %{"get" => %{"tags" => ["x"], "deprecated" => false}}}, "n" => 1.5}

    assert value |> JSON.encode!() |> Elixir.JSON.decode!() == value
  end
end
