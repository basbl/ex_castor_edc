defmodule CastorEDC.E2E.ExportTest do
  @moduledoc """
  Batch exports through `CastorEDC.Export`, against the test study.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.Export
  alias CastorEDC.Exports
  alias CastorEDC.Model.ExportSuccess

  @tag :tmp_dir
  test "looks up a queued export and streams it to disk", %{client: client, study: study, tmp_dir: dir} do
    assert {:ok, %ExportSuccess{queued_exports: [export_id]}} =
             Exports.queue_exports(client, study, %{"exports" => %{"sites" => [%{"format" => "csv"}]}})

    export =
      Enum.find_value(1..30, fn _attempt ->
        Process.sleep(1000)
        {:ok, export} = Export.status(client, study, export_id)
        if export.status == :ready, do: export
      end)

    assert %Export{type: :sites, format: :csv, expires_on: %DateTime{}} = export

    assert {:ok, %Export{path: path}} = Export.download(client, study, export, into: dir)
    assert path == Path.join(dir, export.file_name)
    assert {:ok, [_comment | files]} = :zip.list_dir(String.to_charlist(path))
    assert for({:zip_file, name, _info, _comment, _offset, _size} <- files, do: name) == [~c"sites.csv"]
  end

  test "queues several types at once, returning the IDs in the order asked", %{client: client, study: study} do
    assert {:ok, [sites_id, queries_id]} = Export.queue(client, study, [{:sites, []}, {:queries, format: :excel}])

    Process.sleep(2000)
    assert {:ok, %Export{type: :sites, format: :csv}} = Export.status(client, study, sites_id)
    assert {:ok, %Export{type: :queries, format: :excel}} = Export.status(client, study, queries_id)
  end

  test "queues an export with filters and options", %{client: client, study: study} do
    assert {:ok, [export_id]} =
             Export.queue(client, study, [
               {:participant_data,
                format: :csv,
                filters: [
                  progress: [:not_started, :in_progress, :completed],
                  created_between_start: ~D[2020-01-01],
                  created_between_end: ~D[2100-01-01]
                ],
                options: [display_options_as: :names, include_comments: true]}
             ])

    Process.sleep(2000)
    assert {:ok, %Export{type: :participant_data}} = Export.status(client, study, export_id)
  end
end
