defmodule CastorEDC.ExportTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Error
  alias CastorEDC.Export

  @study "study-1"

  defmodule QueuedAdapter do
    @moduledoc false
    def run(request), do: {request, CastorEDC.Case.json(%{"queued_exports" => ["export-1"]}, status: 201)}
  end

  defp entry(id, attrs \\ %{}) do
    Map.merge(
      %{
        "id" => id,
        "status" => "ready",
        "export_name" => "sites",
        "export_type" => "csv",
        "created_on" => php_date("2026-10-07 21:00:00"),
        "file_name" => "#{id}.zip",
        "file_size" => 2
      },
      attrs
    )
  end

  defp php_date(date), do: %{"date" => date <> ".000000", "timezone_type" => 3, "timezone" => "Europe/Amsterdam"}

  defp list(entries, page \\ 1, page_count \\ 1) do
    json(%{
      "_embedded" => %{"items" => entries},
      "page" => page,
      "page_count" => page_count,
      "page_size" => 100,
      "total_items" => length(entries)
    })
  end

  defp ready(attrs \\ %{}) do
    struct!(
      %Export{
        id: "export-1",
        type: :sites,
        format: :csv,
        status: :ready,
        file_name: "API_Testing_sites.zip",
        expires_on: DateTime.shift(DateTime.utc_now(), hour: 1)
      },
      attrs
    )
  end

  defp zip(_request), do: Req.Response.new(status: 200, body: "PK", headers: %{"content-type" => ["application/zip"]})

  # What the Finch adapter does with `:into`: write the body to the
  # collectable and return the collectable as the body.
  defp streamed(status, body) do
    fn request ->
      into = Enum.into([body], request.into)
      Req.Response.new(status: status, body: into, headers: %{"content-type" => ["application/json"]})
    end
  end

  defp queued(ids), do: json(%{"success" => true, "description" => "Queued", "queued_exports" => ids}, status: 201)

  defp too_many do
    json(%{"description" => "Number of requested concurrent exports exceeds configured maximum (3)."},
      status: 429,
      headers: %{"x-ratelimit-remaining" => ["95"], "x-ratelimit-retry-after" => ["1791452962"]}
    )
  end

  # Answers with the given responses in order.
  defp sequence(responses) do
    {:ok, agent} = Agent.start_link(fn -> responses end)
    fn _request -> Agent.get_and_update(agent, fn [next | rest] -> {next, rest} end) end
  end

  defp sleepy(client) do
    test = self()
    Req.Request.put_private(client, :castor_edc_sleep, fn ms -> send(test, {:slept, ms}) end)
  end

  defp sent_body(request), do: request.body |> IO.iodata_to_binary() |> JSON.decode!()

  describe "queue/4" do
    test "queues an export and returns its ID" do
      client = client(queued(["export-1"]))

      assert {:ok, ["export-1"]} =
               Export.queue(client, @study, [{:participant_data, format: :spss, options: [grouped: true]}])

      request = assert_requested()
      assert request.method == :post
      assert request.url.path == "/api/study/#{@study}/export"
      assert request.headers["accept"] == ["application/json"]

      assert sent_body(request) == %{
               "exports" => %{"participant_data" => [%{"format" => "spss", "options" => %{"grouped" => true}}]}
             }
    end

    test "queues several exports in one request, returning the IDs in the order asked" do
      client = client(queued(["data-1", "data-2", "queries-1", "sites-1"]))

      requests = [
        {:sites, []},
        {:participant_data, format: :csv},
        {:queries, format: :excel},
        {:participant_data, format: :spss}
      ]

      assert {:ok, ["sites-1", "data-1", "queries-1", "data-2"]} = Export.queue(client, @study, requests)

      assert assert_requested() |> sent_body() |> Map.fetch!("exports") == %{
               "participant_data" => [%{"format" => "csv"}, %{"format" => "spss"}],
               "queries" => [%{"format" => "excel"}],
               "sites" => [%{"format" => "csv"}]
             }
    end

    test "writes the types in the order the API's IDs come back in" do
      client = client(queued(["a", "b", "c"]))

      Export.queue(client, @study, [{:sites, []}, {:audit_trail, []}, {:queries, []}])

      body = IO.iodata_to_binary(assert_requested().body)
      assert :binary.match(body, "audit_trail") < :binary.match(body, "queries")
      assert :binary.match(body, "queries") < :binary.match(body, "sites")
    end

    test "raises before sending anything when a request is invalid" do
      client = client(queued([]))

      assert_raise ArgumentError, fn -> Export.queue(client, @study, [{:sites, format: :pdf}]) end
      refute_received {:castor_edc_request, _request}
    end

    test "returns the API's error" do
      client = client(json(%{"description" => "Export format not supported for the requested export type."}, status: 400))

      assert {:error, %Error{status: 400, message: "Export format not supported for the requested export type."}} =
               Export.queue(client, @study, [{:sites, []}])
    end

    test "waits for a slot while three exports are running, backing off" do
      client = [too_many(), too_many(), too_many(), queued(["export-1"])] |> sequence() |> client() |> sleepy()

      assert {:ok, ["export-1"]} = Export.queue(client, @study, [{:sites, []}])

      assert_received {:slept, 5000}
      assert_received {:slept, 10_000}
      assert_received {:slept, 20_000}
      refute_received {:slept, _ms}
    end

    test "backs off to a minute at most" do
      responses = List.duplicate(too_many(), 6) ++ [queued(["export-1"])]
      client = responses |> sequence() |> client() |> sleepy()

      assert {:ok, ["export-1"]} = Export.queue(client, @study, [{:sites, []}], timeout: :infinity)

      for ms <- [5000, 10_000, 20_000, 40_000, 60_000, 60_000], do: assert_received({:slept, ^ms})
    end

    test "gives up with :too_many_exports once the timeout is used up" do
      client = too_many() |> client() |> sleepy()

      assert {:error, %Error{status: 429, code: :too_many_exports, message: message}} =
               Export.queue(client, @study, [{:sites, []}], timeout: 30_000)

      assert message =~ "no slot came free in 15 seconds"
      assert_received {:slept, 5000}
      assert_received {:slept, 10_000}
      refute_received {:slept, _ms}
    end

    test "doesn't wait with rate_limit: :error" do
      client = too_many() |> client(rate_limit: :error) |> sleepy()

      assert {:error, %Error{code: :too_many_exports, message: "three exports are already running"}} =
               Export.queue(client, @study, [{:sites, []}])

      refute_received {:slept, _ms}
    end

    test "emits a telemetry event" do
      ref = :telemetry_test.attach_event_handlers(self(), [[:castor_edc, :export, :queued]])

      Export.queue(client(queued(["export-1"])), @study, [{:sites, []}])

      assert_received {[:castor_edc, :export, :queued], ^ref, %{count: 1},
                       %{study_id: @study, export_ids: ["export-1"], types: [:sites]}}
    end

    test "builds a client from options" do
      assert {:ok, ["export-1"]} = Export.queue([access_token: "t", adapter: QueuedAdapter], @study, [{:sites, []}])
    end
  end

  describe "status/3" do
    test "finds an export in the export list" do
      client = client(json(fixture("list_exports")))

      assert {:ok, export} = Export.status(client, @study, "05ea47e9-8f46-4dbe-afea-5356fd6d488e")

      assert %Export{
               type: :participant_data,
               format: :csv,
               status: :ready,
               file_name: "API_Testing_participant_data_csv_2026_10_07-21_08_47.zip",
               file_size: 11_298,
               created_by: "62C48D56-7A78-45A0-9A26-9A2397F37804",
               data: nil,
               path: nil
             } = export

      assert DateTime.to_iso8601(export.created_on) == "2026-10-07T21:08:46.000000+02:00"
      assert DateTime.to_iso8601(export.expires_on) == "2026-10-14T07:00:00.000000+02:00"

      request = assert_requested()
      assert request.url.path == "/api/study/#{@study}/export"
      assert URI.decode_query(request.url.query) == %{"page" => "1", "page_size" => "100"}
      assert request.headers["accept"] == ["application/json"]
    end

    test "reads failed exports, which have no file" do
      client = client(json(fixture("list_exports")))

      assert {:ok, %Export{status: :failed, type: :empty_crf, format: :pdf, file_name: nil, completed_on: nil}} =
               Export.status(client, @study, "161fbc3c-82ed-4462-99d2-2dc050ef94e5")
    end

    test "pages through the list until it finds the export" do
      client =
        client(fn request ->
          case URI.decode_query(request.url.query)["page"] do
            "1" -> list([entry("other")], 1, 3)
            "2" -> list([entry("export-1")], 2, 3)
          end
        end)

      assert {:ok, %Export{id: "export-1"}} = Export.status(client, @study, "export-1")
      assert_requested()
      assert_requested()
      refute_received {:castor_edc_request, _request}
    end

    test "returns :export_not_found when no page has the export" do
      client =
        client(fn request ->
          case URI.decode_query(request.url.query)["page"] do
            "1" -> list([entry("other")], 1, 2)
            "2" -> list([entry("another")], 2, 2)
          end
        end)

      assert {:error, %Error{code: :export_not_found, message: message}} = Export.status(client, @study, "export-1")
      assert message =~ "export-1"
    end

    test "stops at an empty page, which the API sends past the end" do
      client = client(json(%{"_embedded" => %{"items" => []}, "total_items" => 0}))

      assert {:error, %Error{code: :export_not_found}} = Export.status(client, @study, "export-1")
    end

    test "keeps types, formats and statuses it doesn't know as strings" do
      client = client(list([entry("export-1", %{"export_name" => "new", "export_type" => "parquet", "status" => "x"})]))

      assert {:ok, %Export{type: "new", format: "parquet", status: "x"}} = Export.status(client, @study, "export-1")
    end

    test "returns the error of a failed list request" do
      client = client(json(%{"detail" => "Forbidden"}, status: 403))

      assert {:error, %Error{status: 403}} = Export.status(client, @study, "export-1")
    end
  end

  describe "find/4" do
    test "stops paging once the list passes exports created before the given time" do
      client =
        client(fn _request ->
          list([entry("other", %{"created_on" => php_date("2026-10-07 20:00:00")})], 1, 5)
        end)

      since = ~U[2026-10-07 19:00:00Z]

      assert {:ok, found} = Export.find(client, @study, ["export-1"], since)
      assert found == %{}
      assert_requested()
      refute_received {:castor_edc_request, _request}
    end

    test "finds several exports with one request" do
      client = client(list([entry("export-1"), entry("export-2"), entry("export-3")], 1, 4))

      assert {:ok, found} = Export.find(client, @study, ["export-1", "export-3"])
      assert found |> Map.keys() |> Enum.sort() == ["export-1", "export-3"]
      assert_requested()
      refute_received {:castor_edc_request, _request}
    end
  end

  describe "download/4" do
    test "returns the file in memory" do
      client = client(&zip/1)

      assert {:ok, %Export{data: "PK", path: nil}} = Export.download(client, @study, ready())

      request = assert_requested()
      assert request.url.path == "/api/study/#{@study}/export/export-1/download"
      assert request.headers["accept"] == ["*/*"]
    end

    @tag :tmp_dir
    test "saves the file in a directory under its own name", %{tmp_dir: dir} do
      client = client(&zip/1)

      assert {:ok, %Export{path: path, data: nil}} = Export.download(client, @study, ready(), into: dir)
      assert path == Path.join(dir, "API_Testing_sites.zip")
      assert File.read!(path) == "PK"
    end

    @tag :tmp_dir
    test "creates a directory given with a trailing slash", %{tmp_dir: dir} do
      client = client(&zip/1)

      assert {:ok, %Export{path: path}} = Export.download(client, @study, ready(), into: Path.join(dir, "new") <> "/")
      assert path == Path.join([dir, "new", "API_Testing_sites.zip"])
      assert File.read!(path) == "PK"
    end

    @tag :tmp_dir
    test "saves the file under the given name", %{tmp_dir: dir} do
      client = client(streamed(200, "PK streamed"))
      target = Path.join([dir, "nested", "sites.zip"])

      assert {:ok, %Export{path: ^target}} = Export.download(client, @study, ready(), into: target)
      assert File.read!(target) == "PK streamed"
      assert %File.Stream{path: ^target} = assert_requested().into
    end

    @tag :tmp_dir
    test "names a file without a file name after the export", %{tmp_dir: dir} do
      client = client(&zip/1)

      assert {:ok, %Export{path: path}} = Export.download(client, @study, ready(file_name: nil), into: dir)
      assert path == Path.join(dir, "export-1.zip")
    end

    @tag :tmp_dir
    test "keeps a refused download's body out of the file", %{tmp_dir: dir} do
      client = client(streamed(404, ~s({"detail": "Export not found"})))
      target = Path.join(dir, "sites.zip")

      assert {:error, %Error{status: 404, message: "Export not found"}} =
               Export.download(client, @study, ready(), into: target)

      refute File.exists?(target)
    end

    @tag :tmp_dir
    test "removes the file when the download fails in transit", %{tmp_dir: dir} do
      client = client(%Req.TransportError{reason: :closed})
      target = Path.join(dir, "sites.zip")

      assert {:error, %Error{status: nil}} = Export.download(client, @study, ready(), into: target)
      refute File.exists?(target)
    end

    test "refuses an export that isn't ready" do
      client = client(&zip/1)

      for status <- [:queued, :in_progress, :failed] do
        assert {:error, %Error{code: :export_not_ready, message: message}} =
                 Export.download(client, @study, ready(status: status))

        assert message =~ inspect(status)
      end

      refute_received {:castor_edc_request, _request}
    end

    test "refuses an expired export" do
      client = client(&zip/1)
      export = ready(expires_on: ~U[2026-01-01 06:00:00Z])

      assert {:error, %Error{code: :export_expired, message: message}} = Export.download(client, @study, export)
      assert message =~ "2026-01-01T06:00:00Z"
      refute_received {:castor_edc_request, _request}
    end
  end
end
