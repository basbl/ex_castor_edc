defmodule CastorEDC.E2E.WriteOperationsTest do
  @moduledoc """
  Writing to the test study: participants, data points and exports.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.DataPoints
  alias CastorEDC.Exports
  alias CastorEDC.Fields
  alias CastorEDC.Forms
  alias CastorEDC.Model
  alias CastorEDC.Participants

  setup %{client: client, study: study} do
    fields = client |> Fields.stream_fields(study, include: "optiongroup") |> Enum.to_list()
    forms = client |> Forms.stream_forms(study) |> MapSet.new(& &1.id)
    numeric = Enum.find(fields, &(&1.field_type == "numeric" and MapSet.member?(forms, &1.parent_id)))
    elsewhere = Enum.find(fields, &(&1.field_type == "numeric" and not MapSet.member?(forms, &1.parent_id)))

    %{numeric: numeric, elsewhere: elsewhere, change: %{"change_reason" => "e2e", "confirmed_changes" => true}}
  end

  test "creates a participant", %{client: client, study: study, ids: ids} do
    case Participants.create_participant(client, study, %{"site_id" => ids["site_id"]}) do
      {:ok, %Model.Participant{} = participant} ->
        assert participant.participant_id
        assert_described(participant)

      # A study that has never been live allows only ten participants.
      {:error, %CastorEDC.Error{message: message}} ->
        if message =~ "never been set to live",
          do: IO.puts("\ncreating a participant: skipped, #{message}"),
          else: flunk(message)
    end
  end

  test "writes and reads one data point", %{client: client, study: study, ids: ids, numeric: field} do
    participant = ids["participant_id"]

    assert {:ok, %Model.DataPoint{value: "8"}} =
             DataPoints.create_study_data_point(client, study, participant, field.id, %{
               "field_value" => "8",
               "change_reason" => "e2e",
               "confirmed_changes" => true
             })

    assert {:ok, %Model.DataPoint{value: "8", field_id: field_id}} =
             DataPoints.get_study_data_point(client, study, participant, field.id)

    assert field_id == field.id
  end

  test "reports values a bulk write didn't save", context do
    %{client: client, study: study, ids: ids, numeric: field, elsewhere: elsewhere, change: change} = context

    data = [%{"field_id" => field.id, "field_value" => "9"}, %{"field_id" => elsewhere.id, "field_value" => "9"}]
    body = %{"common" => change, "data" => data}

    assert {:ok, %Model.DataPointsResult{saved: [saved], failed: [failed]}} =
             DataPoints.upsert_study_data_points(client, study, ids["participant_id"], body)

    assert saved.field_id == field.id
    assert failed.field_id == elsewhere.id

    error =
      assert_raise CastorEDC.Error, fn ->
        DataPoints.upsert_study_data_points!(client, study, ids["participant_id"], body)
      end

    assert error.code == :not_saved
  end

  test "queues an export, lists it and downloads it", %{client: client, study: study} do
    assert {:ok, %Model.ExportSuccess{queued_exports: [export_id]}} =
             Exports.queue_exports(client, study, %{"exports" => %{"sites" => [%{"format" => "csv"}]}})

    entry =
      Enum.find_value(1..30, fn _attempt ->
        Process.sleep(1000)
        {:ok, page} = Exports.list_exports(client, study)
        Enum.find(page.entries, &(&1.id == export_id and &1.status == "ready"))
      end)

    assert %Model.ExportEntry{type: "sites", format: "csv", created_on: %DateTime{}} = entry
    assert {:ok, "PK" <> _zip} = Exports.download_export(client, study, export_id)
  end
end
