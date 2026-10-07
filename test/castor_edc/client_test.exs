defmodule CastorEDC.ClientTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client
  alias CastorEDC.Error
  alias CastorEDC.Page

  defmodule Site do
    @moduledoc false
    defstruct [:id, :name]
    def new(data), do: %__MODULE__{id: data["id"], name: data["name"]}
  end

  defp operation(overrides) do
    Keyword.merge(
      [
        method: :get,
        path: "/api/study/{study_id}/site",
        path_params: %{"study_id" => "S1"},
        query_names: %{page: "page", page_size: "page_size", field_ids: "field_ids", site_name: "siteName"},
        decode: Site
      ],
      overrides
    )
  end

  describe "the request" do
    test "interpolates path parameters, encoding each as one segment" do
      Client.request(client(json(%{})), operation(path_params: %{"study_id" => "a/b c"}))

      assert assert_requested().url.path == "/api/study/a%2Fb%20c/site"
    end

    test "sends the operation's options under their wire names and drops nil ones" do
      Client.request(client(json(%{})), operation(query: [page: 2, site_name: "Castor", page_size: nil]))

      assert URI.decode_query(assert_requested().url.query) == %{"page" => "2", "siteName" => "Castor"}
    end

    test "passes options the operation doesn't take to Req" do
      Client.request(client(json(%{})), operation(query: [page: 1, receive_timeout: 1234]))

      request = assert_requested()
      assert request.options.receive_timeout == 1234
      assert URI.decode_query(request.url.query) == %{"page" => "1"}
    end

    test "joins list parameters with commas" do
      Client.request(client(json(%{})), operation(list_params: [:field_ids], query: [field_ids: ["a", "b"]]))

      assert URI.decode_query(assert_requested().url.query) == %{"field_ids" => "a,b"}
    end

    test "lowers a page size above the operation's maximum" do
      Client.request(client(json(%{})), operation(max_page_size: 1000, query: [page_size: 5000]))
      assert URI.decode_query(assert_requested().url.query) == %{"page_size" => "1000"}

      Client.request(client(json(%{})), operation(max_page_size: 1000, query: [page_size: 50]))
      assert URI.decode_query(assert_requested().url.query) == %{"page_size" => "50"}
    end

    test "accepts HAL JSON unless the operation says otherwise" do
      Client.request(client(json(%{})), operation([]))
      assert Req.Request.get_header(assert_requested(), "accept") == ["application/hal+json"]

      Client.request(client(json(%{})), operation(accept: "application/json"))
      assert Req.Request.get_header(assert_requested(), "accept") == ["application/json"]
    end

    test "sends a body as JSON" do
      Client.request(client(json(%{}, status: 201)), operation(method: :post, body: %{"site_name" => "Castor"}))

      request = assert_requested()
      assert request.method == :post
      assert request.body |> IO.iodata_to_binary() |> JSON.decode!() == %{"site_name" => "Castor"}
    end

    test "marks the request with its route for rate limiting" do
      Client.request(client(json(%{})), operation([]))

      assert Req.Request.get_private(assert_requested(), :castor_edc_route) == "/api/study/{study_id}/site"
    end
  end

  describe "a response" do
    test "decodes into the operation's struct" do
      assert {:ok, %Site{id: "1", name: "Castor"}} =
               Client.request(client(json(%{"id" => "1", "name" => "Castor"})), operation([]))
    end

    test "is returned as it arrived without a struct to decode into" do
      assert {:ok, %{"id" => "1"}} = Client.request(client(json(%{"id" => "1"})), operation(decode: nil))
    end

    test "without a body is nil" do
      assert {:ok, nil} = Client.request(client(Req.Response.new(status: 204)), operation(method: :delete))
    end

    test "of a paged collection becomes a page" do
      body = %{
        "_embedded" => %{"sites" => [%{"id" => "1"}, %{"id" => "2"}]},
        "_links" => %{},
        "page" => 2,
        "page_count" => 3,
        "page_size" => 2,
        "total_items" => 6
      }

      assert {:ok, page} = Client.request(client(json(body)), operation(items: "_embedded.sites"))

      assert page == %Page{
               entries: [%Site{id: "1"}, %Site{id: "2"}],
               page: 2,
               page_count: 3,
               page_size: 2,
               total_items: 6
             }
    end

    test "of a collection returned whole is page 1 of 1" do
      body = %{"_embedded" => %{"roles" => [%{"id" => "1"}]}, "total_items" => 1}

      assert {:ok, %Page{entries: [%Site{}], page: 1, page_count: 1, page_size: 1, total_items: 1}} =
               Client.request(client(json(body)), operation(items: "_embedded.roles"))
    end

    test "of an empty collection is page 1 of 0, although the API says page 0" do
      body = %{"_embedded" => %{"items" => []}, "page" => 0, "page_count" => 0, "page_size" => 25, "total_items" => 0}

      assert {:ok, %Page{entries: [], page: 1, page_count: 0, total_items: 0}} =
               Client.request(client(json(body)), operation(items: "_embedded.items"))
    end

    test "of a collection that isn't HAL still becomes a page" do
      assert {:ok, %Page{entries: [%Site{id: "2"}], total_items: 250}} =
               Client.request(
                 client(json(%{"totals" => 250, "results" => [%{"id" => "2"}]})),
                 operation(items: "results")
               )

      assert {:ok, %Page{entries: [], page_count: 0, total_items: 0}} =
               Client.request(client(json(%{"total" => 0, "data" => []})), operation(items: "data"))
    end

    test "404 is an empty page for collections that answer it when empty" do
      not_found = json(%{"detail" => "There are no repeating data instances."}, status: 404)

      assert {:ok, %Page{entries: [], page_count: 0}} =
               Client.request(
                 client(not_found),
                 operation(items: "_embedded.repeatingDataInstance", not_found_is_empty: true)
               )

      assert {:error, %Error{status: 404}} = Client.request(client(not_found), operation(items: "_embedded.sites"))
    end

    test "with an error status becomes an error" do
      assert {:error, %Error{status: 403, message: "Forbidden for you"}} =
               Client.request(client(json(%{"detail" => "Forbidden for you"}, status: 403)), operation([]))
    end

    test "that never arrived becomes an error" do
      assert {:error, %Error{status: nil, reason: %Req.TransportError{reason: :econnrefused}}} =
               Client.request(client(%Req.TransportError{reason: :econnrefused}), operation([]))
    end
  end

  describe "request!/2" do
    test "returns the result or raises the error" do
      assert %Site{id: "1"} = Client.request!(client(json(%{"id" => "1"})), operation([]))

      assert_raise Error, "Gone", fn ->
        Client.request!(client(json(%{"detail" => "Gone"}, status: 410)), operation([]))
      end
    end

    test "raises when a partially successful write saved nothing or only some values" do
      body = %{
        "success" => [%{"field_id" => "f1", "field_value" => "1"}],
        "failed" => [%{"field_id" => "f2", "code" => "BAD_REQUEST", "message" => "Unsupported field type"}],
        "total_failed" => 1
      }

      error =
        assert_raise Error, fn ->
          Client.request!(client(json(body, status: 201)), operation(method: :post, decode: nil, partial_success: true))
        end

      assert error.code == :not_saved
      assert error.message == "1 value(s) were not saved: f2: Unsupported field type"
      assert error.details == [%{code: "BAD_REQUEST", message: "Unsupported field type", field: "f2"}]
    end

    test "returns a partially successful write when everything was saved" do
      body = %{"success" => [%{"field_id" => "f1"}], "failed" => []}

      assert %{"failed" => []} =
               Client.request!(
                 client(json(body, status: 201)),
                 operation(method: :post, decode: nil, partial_success: true)
               )
    end
  end
end

defmodule CastorEDC.ClientTelemetryTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client

  @operation [method: :get, path: "/api/study/{study_id}", path_params: %{"study_id" => "S1"}, query_names: %{}]

  setup do
    events = [[:castor_edc, :request, :start], [:castor_edc, :request, :stop]]
    %{ref: :telemetry_test.attach_event_handlers(self(), events)}
  end

  test "spans every operation, with the route rather than the path", %{ref: ref} do
    Client.request(client(json(%{})), @operation)

    assert_received {[:castor_edc, :request, :start], ^ref, %{system_time: _time}, start}
    assert %{method: :get, route: "/api/study/{study_id}", base_url: "https://data.castoredc.com"} = start

    assert_received {[:castor_edc, :request, :stop], ^ref, %{duration: duration}, %{status: :ok}}
    assert is_integer(duration)
  end

  test "reports a failure's status and error", %{ref: ref} do
    Client.request(client(json(%{"detail" => "Gone"}, status: 404)), @operation)

    assert_received {[:castor_edc, :request, :stop], ^ref, _measurements, %{status: 404, error: %CastorEDC.Error{}}}
  end
end
