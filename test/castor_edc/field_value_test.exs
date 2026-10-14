defmodule CastorEDC.FieldValueTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias CastorEDC.FieldValue
  alias CastorEDC.MissingValue
  alias CastorEDC.Model.Field
  alias CastorEDC.Model.FieldOption
  alias CastorEDC.Model.FieldOptionGroup
  alias CastorEDC.PartialDate

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

  test "takes the field type as an atom too" do
    assert FieldValue.decode("42", :numeric) == 42
    assert FieldValue.decode("05-10-2026", :date) == ~D[2026-10-05]
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

  describe "dates and times" do
    test "decodes dates, in both stored forms" do
      assert FieldValue.decode("07-10-2026", "date") == ~D[2026-10-07]
      assert FieldValue.decode("07102026", "date") == ~D[2026-10-07]
      assert FieldValue.decode("29-02-2024", "date") == ~D[2024-02-29]
    end

    test "decodes partial dates" do
      assert FieldValue.decode("00-05-2020", "date_partial") == %PartialDate{year: 2020, month: 5, day: nil}
      assert FieldValue.decode("00-00-2020", "date_partial") == %PartialDate{year: 2020, month: nil, day: nil}
      assert FieldValue.decode("03-05-2020", "date_partial") == %PartialDate{year: 2020, month: 5, day: 3}
      assert FieldValue.decode("00002020", "date_partial") == %PartialDate{year: 2020}
    end

    test "decodes times" do
      assert FieldValue.decode("12:30", "time") == ~T[12:30:00]
      assert FieldValue.decode("08:05:09", "time") == ~T[08:05:09]
    end

    test "decodes dates with a time" do
      assert FieldValue.decode("07-10-2026;12:30", "datetime") == ~N[2026-10-07 12:30:00]
    end

    test "decodes numbers with a date, either of which may be missing" do
      assert FieldValue.decode("5;07-10-2026", "numberdate") == {5, ~D[2026-10-07]}
      assert FieldValue.decode("2.5;07102026", "numberdate") == {2.5, ~D[2026-10-07]}
      assert FieldValue.decode("5;", "numberdate") == {5, nil}
      assert FieldValue.decode(";07-10-2026", "numberdate") == {nil, ~D[2026-10-07]}
    end

    test "keeps values that aren't dates or times as strings" do
      capture_log(fn ->
        for {raw, type} <- [
              {"2026-10-07", "date"},
              {"31-02-2026", "date"},
              {"00-05-2020", "date"},
              {"7-10-2026", "date"},
              {"ab-cd-efgh", "date"},
              {"03-00-2020", "date_partial"},
              {"30-02-2020", "date_partial"},
              {"25:00", "time"},
              {"noon", "time"},
              {"07-10-2026 12:30", "datetime"},
              {"07-10-2026;", "datetime"},
              {"five;07-10-2026", "numberdate"},
              {"5;tomorrow", "numberdate"},
              {"5", "numberdate"}
            ] do
          assert FieldValue.decode(raw, field(type)) == raw
        end
      end)
    end
  end

  describe "options" do
    @group %FieldOptionGroup{
      options: [
        %FieldOption{value: "0", name: "None"},
        %FieldOption{value: "1", name: "Mild"},
        %FieldOption{value: "2", name: "Severe"}
      ]
    }

    test "decodes a radio or dropdown value as the option's value" do
      assert FieldValue.decode("2", "radio") == "2"
      assert FieldValue.decode("197", "dropdown") == "197"
    end

    test "decodes a checkbox value as the list of checked values" do
      assert FieldValue.decode("0;1", "checkbox") == ["0", "1"]
      assert FieldValue.decode("2", "checkbox") == ["2"]
    end

    test "looks up an option's name" do
      assert FieldValue.label("2", @group) == "Severe"
      assert FieldValue.label("3", @group) == nil
      assert FieldValue.label(["0", "1"], @group) == ["None", "Mild"]
    end

    test "looks up names through a field listed with its option group" do
      assert FieldValue.label("1", %Field{field_type: "radio", option_group: @group}) == "Mild"
      assert FieldValue.label("1", %Field{field_type: "radio", option_group: nil}) == nil
      assert FieldValue.label("1", %FieldOptionGroup{options: nil}) == nil
    end
  end

  describe "grids, uploads and locations" do
    test "decodes a grid as rows of cells" do
      assert FieldValue.decode(~s({"0":{"0":"5","1":""},"1":{"0":"text","1":"##USER_MISSING_96##"}}), "grid") == %{
               0 => %{0 => "5", 1 => nil},
               1 => %{0 => "text", 1 => MissingValue.new(96)}
             }
    end

    test "keeps grid keys that aren't numbers, and reads numbers and nulls in cells" do
      assert FieldValue.decode(~s({"a":{"b":7,"c":null}}), "grid") == %{"a" => %{"b" => "7", "c" => nil}}
    end

    test "decodes an upload as the file's name" do
      assert FieldValue.decode("-- Uploaded File: scan 1.pdf --", "upload") == {:upload, "scan 1.pdf"}
      assert FieldValue.decode("- - Uploaded file - -", "upload") == {:upload, nil}

      # The lists describe it as JSON, with the name base64-encoded.
      listed = ~s({"file_name":"aGVsbG8udHh0","mime_type":"text\\/plain","file_size":22,"storage_path":"E5F2A8E0"})
      assert FieldValue.decode(listed, "upload") == {:upload, "hello.txt"}
    end

    test "decodes a location as latitude and longitude" do
      assert FieldValue.decode("52.3676;4.9041", "geolocation") == {52.3676, 4.9041}
      assert FieldValue.decode("-33; 151", "geolocation") == {-33.0, 151.0}
    end

    test "keeps grids, uploads and locations it can't read as strings" do
      capture_log(fn ->
        for {raw, type} <- [
              {"{not json", "grid"},
              {~s(["a"]), "grid"},
              {~s({"0":"a"}), "grid"},
              {"scan.pdf", "upload"},
              {"-- Uploaded File: scan.pdf", "upload"},
              {~s({"file_name":"not base64!"}), "upload"},
              {~s({"mime_type":"text/plain"}), "upload"},
              {"{not json", "upload"},
              {"52.3", "geolocation"},
              {"north;south", "geolocation"}
            ] do
          assert FieldValue.decode(raw, field(type)) == raw
        end
      end)
    end
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
