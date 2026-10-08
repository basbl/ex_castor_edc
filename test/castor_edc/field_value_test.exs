defmodule CastorEDC.FieldValueTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias CastorEDC.FieldValue
  alias CastorEDC.MissingValue
  alias CastorEDC.Model.Field

  doctest FieldValue

  defp field(type, attrs \\ []) do
    struct!(%Field{id: "field-#{System.unique_integer([:positive])}", field_type: type}, attrs)
  end

  describe "any field type" do
    test "decodes an empty value as nil" do
      for type <- ~w(numeric string date checkbox grid unknown), raw <- [nil, ""] do
        assert FieldValue.decode(raw, type) == nil
      end
    end

    test "decodes missing-value codes" do
      for type <- ~w(numeric year string calculation date) do
        assert FieldValue.decode("##USER_MISSING_95##", type) == MissingValue.new(95)
        assert FieldValue.decode("##USER_MISSING_99##", field(type)) == MissingValue.new(99)
      end
    end

    test "decodes encrypted values" do
      assert FieldValue.decode("*encrypted*", "numeric") == :encrypted
      assert FieldValue.decode("*encrypted*", "string") == :encrypted
    end
  end

  test "decodes numbers" do
    for type <- ~w(numeric slider) do
      assert FieldValue.decode("42", type) === 42
      assert FieldValue.decode("-7", type) === -7
      assert FieldValue.decode("3.14", type) === 3.14
      assert FieldValue.decode("-0.5", type) === -0.5
    end
  end

  test "decodes years" do
    assert FieldValue.decode("2015", "year") === 2015
    assert FieldValue.decode("1891", field("year")) === 1891
  end

  test "decodes text as it is" do
    for type <- ~w(string textarea randomization remark something_new) do
      assert FieldValue.decode("e2e text; with a semicolon", type) == "e2e text; with a semicolon"
    end
  end

  test "decodes a calculation as a number when it is one" do
    assert FieldValue.decode("12", "calculation") === 12
    assert FieldValue.decode("22.5", "calculation") === 22.5
    assert FieldValue.decode("Obese", "calculation") == "Obese"
    assert FieldValue.decode("NaN", "calculation") == "NaN"
  end

  describe "a value that doesn't read as its type" do
    test "comes back as the string, with a warning" do
      field = field("numeric", field_variable_name: "weight")

      log = capture_log(fn -> assert FieldValue.decode("12,5", field) == "12,5" end)

      assert log =~ ~s(couldn't read "12,5" as a numeric value of field weight)
    end

    test "warns once per field" do
      field = field("year")

      assert capture_log(fn -> FieldValue.decode("two thousand", field) end) =~ "year value"
      assert capture_log(fn -> FieldValue.decode("MMXV", field) end) == ""
      assert capture_log(fn -> FieldValue.decode("MMXV", field("year")) end) =~ "year value"
    end

    test "names the field by its ID without a variable name" do
      field = field("numeric")
      assert capture_log(fn -> FieldValue.decode("1.2.3", field) end) =~ "of field #{field.id}"
    end

    test "warns once per type when only the type is given" do
      type = "numeric"
      capture_log(fn -> FieldValue.decode("x", type) end)
      assert capture_log(fn -> FieldValue.decode("y", type) end) == ""
    end
  end
end
