defmodule CastorEDC.E2E.ExportTest do
  @moduledoc """
  Batch exports through `CastorEDC.Export`, against the test study.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.Error
  alias CastorEDC.Export

  @tag :tmp_dir
  test "queues an export, waits for it and streams it to disk", %{client: client, study: study, tmp_dir: dir} do
    since = DateTime.shift(DateTime.utc_now(), minute: -1)
    assert {:ok, [export_id]} = Export.queue(client, study, [{:sites, []}])

    assert {:ok, [export]} = Export.await(client, study, [export_id], since: since, timeout: 60_000)
    assert %Export{id: ^export_id, type: :sites, format: :csv, status: :ready, expires_on: %DateTime{}} = export
    assert {:ok, ^export} = Export.status(client, study, export_id)

    assert {:ok, %Export{path: path}} = Export.download(client, study, export, into: dir)
    assert path == Path.join(dir, export.file_name)
    assert {:ok, [_comment | files]} = :zip.list_dir(String.to_charlist(path))
    assert for({:zip_file, name, _info, _comment, _offset, _size} <- files, do: name) == [~c"sites.csv"]
  end

  test "queues several types at once, returning the IDs in the order asked", %{client: client, study: study} do
    assert {:ok, [sites_id, queries_id]} = Export.queue(client, study, [{:sites, []}, {:queries, format: :excel}])

    assert {:ok, [%Export{type: :sites, format: :csv}, %Export{type: :queries, format: :excel}]} =
             Export.await(client, study, [sites_id, queries_id], timeout: 60_000)
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

    assert {:ok, [%Export{type: :participant_data, status: :ready}]} =
             Export.await(client, study, [export_id], timeout: 60_000)
  end

  test "doesn't find an export that doesn't exist", %{client: client, study: study} do
    assert {:error, %Error{code: :export_not_found}} =
             Export.status(client, study, "00000000-0000-0000-0000-000000000000")
  end
end
