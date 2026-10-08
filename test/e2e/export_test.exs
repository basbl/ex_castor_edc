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
end
