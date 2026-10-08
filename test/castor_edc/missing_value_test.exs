defmodule CastorEDC.MissingValueTest do
  use ExUnit.Case, async: true

  alias CastorEDC.MissingValue

  doctest MissingValue

  test "knows the five codes and their reasons" do
    assert Enum.map(95..99, &MissingValue.new(&1).reason) ==
             [:measurement_failed, :not_applicable, :not_asked, :asked_but_unknown, :not_done]

    assert MissingValue.new(94) == nil
    assert MissingValue.new(100) == nil
  end

  test "reads only the stored form of a known code" do
    for code <- 95..99 do
      assert %MissingValue{code: ^code} = MissingValue.parse(MissingValue.to_wire(MissingValue.new(code)))
    end

    for other <- ["##USER_MISSING_94##", "##USER_MISSING_9x##", "##USER_MISSING_95", "-95", "##USER_MISSING_100##"] do
      assert MissingValue.parse(other) == nil
    end
  end
end
