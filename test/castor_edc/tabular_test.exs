defmodule CastorEDC.TabularTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Error
  alias CastorEDC.Tabular

  doctest Tabular

  @study "study-1"

  defp page(key, items), do: json(%{"_embedded" => %{key => items}, "page" => 1, "page_count" => 1})

  defp field(id, type, parent, attrs \\ %{}) do
    Map.merge(
      %{
        "id" => id,
        "field_type" => type,
        "field_variable_name" => "var_#{id}",
        "field_label" => "Label #{id}",
        "parent_id" => parent
      },
      attrs
    )
  end

  defp fields do
    [
      field("f-weight", "numeric", "form-1"),
      field("f-sex", "radio", "form-1", %{
        "option_group" => %{"id" => "og-1", "options" => [%{"value" => "1", "name" => "Female"}]}
      }),
      field("f-remark", "remark", "form-1"),
      field("f-bp", "numeric", "rd-form-1"),
      field("f-gad", "checkbox", "survey-form-1"),
      field("f-orphan", "date", "elsewhere"),
      field("f-new", "hologram", "form-1")
    ]
  end

  # Answers each collection the schema needs, by path.
  defp study(request) do
    case String.replace_prefix(request.url.path, "/api/study/#{@study}", "") do
      "/field" ->
        page("fields", fields())

      "/form" ->
        page("forms", [
          %{
            "id" => "form-1",
            "form_name" => "Baseline",
            "_embedded" => %{"visit" => %{"id" => "visit-1", "visit_name" => "Screening"}}
          }
        ])

      "/repeating-data" ->
        page("repeatingData", [%{"id" => "rd-1", "name" => "Blood pressure"}])

      "/repeating-data/rd-1/repeating-data-form" ->
        page("repeating_data_forms", [%{"id" => "rd-form-1", "repeating_data_form_name" => "Measurement"}])

      "/survey" ->
        page("surveys", [%{"id" => "survey-1", "name" => "GAD-7"}])

      "/survey/survey-1/survey-form" ->
        page("survey_forms", [%{"id" => "survey-form-1", "survey_form_name" => "Questions"}])
    end
  end

  describe "schema/2" do
    test "describes every field that collects data" do
      assert {:ok, schema} = Tabular.schema(client(&study/1), @study)

      assert schema |> Map.keys() |> Enum.sort() == ~w(f-bp f-gad f-new f-orphan f-sex f-weight)

      assert %{
               field_id: "f-weight",
               variable_name: "var_f-weight",
               label: "Label f-weight",
               field_type: "numeric",
               type: :number,
               context: :study,
               parent_id: "visit-1",
               parent_name: "Screening",
               form_id: "form-1",
               form_name: "Baseline",
               option_group: nil,
               field: %CastorEDC.Model.Field{id: "f-weight"}
             } = schema["f-weight"]
    end

    test "finds each field's context through its form" do
      assert {:ok, schema} = Tabular.schema(client(&study/1), @study)

      assert %{context: :repeating_data, parent_name: "Blood pressure", form_name: "Measurement"} = schema["f-bp"]
      assert %{context: :survey, parent_id: "survey-1", parent_name: "GAD-7", form_name: "Questions"} = schema["f-gad"]
      assert %{context: nil, parent_id: nil, form_id: nil} = schema["f-orphan"]
    end

    test "gives each field the type of its values, and keeps option groups" do
      assert {:ok, schema} = Tabular.schema(client(&study/1), @study)

      assert schema["f-gad"].type == {:list, :string}
      assert schema["f-orphan"].type == :date
      assert schema["f-new"].type == :string
      assert %{type: :string, option_group: %{id: "og-1", options: [%{name: "Female"}]}} = schema["f-sex"]
    end

    test "asks for fields with their option groups" do
      Tabular.schema(client(&study/1), @study)

      requests = for _request <- 1..6, do: assert_requested()
      fields = Enum.find(requests, &(&1.url.path == "/api/study/#{@study}/field"))
      assert URI.decode_query(fields.url.query)["include"] == "optiongroup"
    end

    test "returns the error of any request" do
      client =
        client(fn request ->
          if String.ends_with?(request.url.path, "/survey"),
            do: json(%{"detail" => "Forbidden"}, status: 403),
            else: study(request)
        end)

      assert {:error, %Error{status: 403}} = Tabular.schema(client, @study)
    end
  end

  test "maps every field type to the type of its values" do
    for {field_type, type} <- [
          {"numeric", :number},
          {"slider", :number},
          {"year", :integer},
          {"calculation", :number_or_string},
          {"string", :string},
          {"textarea", :string},
          {"date", :date},
          {"date_partial", :partial_date},
          {"time", :time},
          {"datetime", :naive_datetime},
          {"numberdate", {:number, :date}},
          {"radio", :string},
          {"dropdown", :string},
          {"checkbox", {:list, :string}},
          {"grid", :grid},
          {"upload", :upload},
          {"geolocation", :geolocation}
        ] do
      assert Tabular.value_type(field_type) == type
    end
  end
end
