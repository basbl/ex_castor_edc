defmodule CastorEDC.Export.RequestTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Export.Request

  test "knows every export type of the spec" do
    assert Request.types() ==
             ~w(audit_trail domain_mapping empty_crf form_structure participant_casebook participant_data queries
                sites survey_compliance uploaded_files validations)a
  end

  test "defaults to the type's first format" do
    assert Request.encode(:participant_data, []) == %{"format" => "csv"}
    assert Request.encode(:participant_casebook, []) == %{"format" => "pdf"}
    assert Request.encode(:form_structure, []) == %{"format" => "xml"}
    assert Request.encode(:uploaded_files, []) == %{"format" => "zip"}
  end

  test "takes the format as an atom or a string" do
    assert Request.encode(:participant_data, format: :sas_7bdat) == %{"format" => "sas_7bdat"}
    assert Request.encode(:participant_data, format: "spss") == %{"format" => "spss"}
  end

  test "encodes filters and options by their schema" do
    entry =
      Request.encode(:participant_data,
        format: :excel,
        filters: [
          site_ids: ["S1", "S2"],
          locked: false,
          progress: [:not_started, :completed],
          created_between_start: ~D[2026-01-01],
          last_updated_between_end: "2026-02-01",
          elements: [visits: ["V1"], repeating_data: []]
        ],
        options: %{"grouped" => true, display_options_as: :names, export_missing_data_in: "separate_column"}
      )

    assert entry == %{
             "format" => "excel",
             "filters" => %{
               "site_ids" => ["S1", "S2"],
               "locked" => false,
               "progress" => ["not_started", "completed"],
               "created_between_start" => "2026-01-01",
               "last_updated_between_end" => "2026-02-01",
               "elements" => %{"visits" => ["V1"], "repeating_data" => []}
             },
             "options" => %{
               "grouped" => true,
               "display_options_as" => "names",
               "export_missing_data_in" => "separate_column"
             }
           }
  end

  test "sends values the spec renames under their wire name" do
    assert Request.encode(:form_structure, filters: [element_type: :visit])["filters"] == %{"element_type" => "phase"}

    assert Request.encode(:form_structure, filters: [element_type: :repeating_data_form])["filters"] ==
             %{"element_type" => "report_step"}

    assert Request.encode(:form_structure, filters: [element_type: :phase])["filters"] == %{"element_type" => "phase"}
    assert Request.encode(:form_structure, filters: [element_type: :all])["filters"] == %{"element_type" => "all"}
  end

  test "takes atoms for values with spaces and symbols" do
    filters =
      Request.encode(:survey_compliance,
        filters: [survey_package_status: [:in_progress, "Sent"], compliance_operator: :>=, compliance_value: 80]
      )["filters"]

    assert filters == %{
             "survey_package_status" => ["In Progress", "Sent"],
             "compliance_operator" => ">=",
             "compliance_value" => 80
           }
  end

  test "formats times where the API takes a date and time" do
    filters =
      Request.encode(:survey_compliance,
        filters: [availability_start: ~N[2026-01-01 11:11:59], availability_end: ~U[2026-02-01 08:00:00Z]]
      )["filters"]

    assert filters == %{"availability_start" => "2026-01-01 11:11", "availability_end" => "2026-02-01 08:00"}

    assert Request.encode(:queries, filters: [created_between_start: ~D[2026-01-01]])["filters"] ==
             %{"created_between_start" => "2026-01-01"}
  end

  describe "raises ArgumentError" do
    test "for an unknown type" do
      assert_raise ArgumentError, ~r/unknown export type :participants; expected one of :audit_trail/, fn ->
        Request.encode(:participants, [])
      end
    end

    test "for a format the type doesn't support" do
      assert_raise ArgumentError, ~r/a sites export can't be in format :excel; expected one of :csv/, fn ->
        Request.encode(:sites, format: :excel)
      end
    end

    test "for an unknown filter or option, listing the known ones" do
      assert_raise ArgumentError, ~r/unknown participant_data export filter :site_id; expected one of .*:site_ids/, fn ->
        Request.encode(:participant_data, filters: [site_id: "S1"])
      end

      assert_raise ArgumentError, ~r/unknown empty_crf export option :title_page/, fn ->
        Request.encode(:empty_crf, options: [title_page: true])
      end

      assert_raise ArgumentError,
                   ~r/unknown participant_data export filter :elements :sites; expected one of :forms/,
                   fn ->
                     Request.encode(:participant_data, filters: [elements: [sites: []]])
                   end
    end

    test "for any filter or option of a type that has none" do
      assert_raise ArgumentError, ~r/a sites export filter :site_ids isn't supported; there are none/, fn ->
        Request.encode(:sites, filters: [site_ids: ["S1"]])
      end

      assert_raise ArgumentError, ~r/a queries export option :grouped isn't supported/, fn ->
        Request.encode(:queries, options: [grouped: true])
      end
    end

    test "for an option other than format, filters and options" do
      assert_raise ArgumentError, ~r/unknown option\(s\) \[:filter\] for a sites export/, fn ->
        Request.encode(:sites, filter: [])
      end
    end

    test "for a value of the wrong kind" do
      for {filters, message} <- [
            {[locked: "yes"], ~r/expected participant_data export filter :locked to be a boolean, got: "yes"/},
            {[site_ids: "S1"], ~r/:site_ids to be a list/},
            {[site_ids: [1]], ~r/:site_ids to be a string, got: 1/},
            {[progress: [:done]], ~r/:progress to be one of :not_started, :in_progress, :completed, :archived/},
            {[created_between_start: 2026], ~r/:created_between_start to be a Date or a string/},
            {[elements: "V1"], ~r/:elements to be a keyword list/}
          ] do
        assert_raise ArgumentError, message, fn -> Request.encode(:participant_data, filters: filters) end
      end

      assert_raise ArgumentError, ~r/:compliance_value to be an integer/, fn ->
        Request.encode(:survey_compliance, filters: [compliance_value: "80"])
      end

      assert_raise ArgumentError, ~r/:availability_start to be a date or a string/, fn ->
        Request.encode(:survey_compliance, filters: [availability_start: 1])
      end

      assert_raise ArgumentError, ~r/:element_type to be one of :all, :study, :visit, :form/, fn ->
        Request.encode(:form_structure, filters: [element_type: :page])
      end
    end
  end
end
