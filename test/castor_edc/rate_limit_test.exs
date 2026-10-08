defmodule CastorEDC.RateLimitTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client
  alias CastorEDC.RateLimit

  doctest RateLimit

  @headers %{
    "x-ratelimit-limit" => ["6000"],
    "x-ratelimit-remaining" => ["5999"],
    "x-ratelimit-retry-after" => ["1791399750"]
  }

  setup do
    %{base_url: "https://test-#{System.unique_integer([:positive])}.invalid"}
  end

  defp operation(path),
    do: [method: :get, path: path, path_params: %{"study_id" => "S", "field_id" => "F"}, query_names: %{}]

  test "parses the rate limit headers, with the reset time as a Unix timestamp" do
    assert RateLimit.parse(@headers) == %{limit: 6000, remaining: 5999, reset_at: ~U[2026-10-07 19:02:30Z]}
    assert RateLimit.parse(%{"x-ratelimit-remaining" => ["3"]}) == %{limit: nil, remaining: 3, reset_at: nil}
    assert RateLimit.parse(%{"content-type" => ["application/json"]}) == nil
    assert RateLimit.parse(%{"x-ratelimit-limit" => ["many"]}) == nil
  end

  test "records the rate limit of every response for its route", %{base_url: base_url} do
    client = client(json(%{}, headers: @headers), base_url: base_url)

    Client.request(client, operation("/api/study/{study_id}/field"))

    assert RateLimit.lookup(assert_requested()).remaining == 5999
  end

  test "a collection and its items share a bucket", %{base_url: base_url} do
    remaining = fn n -> json(%{}, headers: Map.put(@headers, "x-ratelimit-remaining", ["#{n}"])) end

    Client.request(client(remaining.(10), base_url: base_url), operation("/api/study/{study_id}/field"))
    Client.request(client(remaining.(9), base_url: base_url), operation("/api/study/{study_id}/field/{field_id}"))

    assert RateLimit.lookup(assert_requested()).remaining == 9
    assert RateLimit.lookup(assert_requested()).remaining == 9
  end

  test "keeps buckets apart per route, server and credentials", %{base_url: base_url} do
    Client.request(client(json(%{}, headers: @headers), base_url: base_url), operation("/api/study/{study_id}/field"))
    field = assert_requested()

    Client.request(client(json(%{}), base_url: base_url), operation("/api/study/{study_id}/visit"))
    assert RateLimit.lookup(assert_requested()) == nil

    Client.request(client(json(%{}), base_url: base_url, access_token: "other"), operation("/api/study/{study_id}/field"))
    assert RateLimit.lookup(assert_requested()) == nil

    assert RateLimit.lookup(field).remaining == 5999
  end

  test "ignores requests made without an operation" do
    client = client(json(%{}, headers: @headers))

    Req.get!(client, url: "/api/study")
    assert RateLimit.lookup(assert_requested()) == nil
  end
end

defmodule CastorEDC.RateLimitRetryTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client
  alias CastorEDC.Error

  @operation [method: :get, path: "/api/study", query_names: %{}]
  @now 1_791_399_700

  defp limited(reset_in) do
    json(%{"success" => false, "errors" => [%{"code" => "CODE_QUOTA_EXCEEDED", "message" => "Too many requests"}]},
      status: 429,
      headers: %{
        "x-ratelimit-limit" => ["600"],
        "x-ratelimit-remaining" => ["0"],
        "x-ratelimit-retry-after" => [Integer.to_string(@now + reset_in)]
      }
    )
  end

  # Answers with the given responses in order, then with 200.
  defp sequence(responses) do
    {:ok, agent} = Agent.start_link(fn -> responses end)

    fn _request ->
      Agent.get_and_update(agent, fn
        [next | rest] -> {next, rest}
        [] -> {json(%{"ok" => true}), []}
      end)
    end
  end

  # Every client gets its own server: rate limits recorded by one test
  # would otherwise hold back the next.
  defp limited_client(responder, options \\ []) do
    test = self()

    responder
    |> client(Keyword.put(options, :base_url, "https://test-#{System.unique_integer([:positive])}.invalid"))
    |> Req.Request.put_private(:castor_edc_clock, fn -> @now end)
    |> Req.Request.put_private(:castor_edc_sleep, fn ms -> send(test, {:slept, ms}) end)
  end

  test "waits until the window resets and sends the request again" do
    assert {:ok, %{"ok" => true}} = Client.request(limited_client(sequence([limited(30)])), @operation)

    assert_received {:slept, 30_000}
    assert_requested()
    assert_requested()
  end

  test "retries any method, since a 429 is refused before anything happens" do
    assert {:ok, %{"ok" => true}} =
             Client.request(limited_client(sequence([limited(1)])), Keyword.put(@operation, :method, :post))

    assert_received {:slept, 1000}
  end

  test "gives up after three attempts" do
    client = limited_client(sequence(List.duplicate(limited(1), 4)))

    assert {:error, %Error{status: 429}} = Client.request(client, @operation)
    for _attempt <- 1..3, do: assert_received({:slept, 1000})
    refute_received {:slept, _ms}
  end

  test "returns the 429 right away with rate_limit: :error" do
    client = limited_client(sequence([limited(30)]), rate_limit: :error)

    assert {:error, %Error{status: 429, code: "CODE_QUOTA_EXCEEDED", rate_limit: %{remaining: 0, limit: 600}}} =
             Client.request(client, @operation)

    refute_received {:slept, _ms}
  end

  test "returns the 429 when the wait would be longer than max_rate_limit_wait" do
    client = limited_client(sequence([limited(90)]), max_rate_limit_wait: 60_000)

    assert {:error, %Error{status: 429}} = Client.request(client, @operation)
    refute_received {:slept, _ms}
  end

  test "returns a 429 that doesn't say when the window resets" do
    no_reset = json(%{"detail" => "Too many concurrent exports"}, status: 429)

    assert {:error, %Error{status: 429, retry_after: nil}} =
             Client.request(limited_client(sequence([no_reset])), @operation)
  end

  test "returns a 429 whose headers say requests remain, such as the batch export limit" do
    too_many_exports =
      json(%{"description" => "Number of requested concurrent exports exceeds configured maximum (3)."},
        status: 429,
        headers: %{
          "x-ratelimit-limit" => ["100"],
          "x-ratelimit-remaining" => ["95"],
          "x-ratelimit-retry-after" => [Integer.to_string(@now + 30)]
        }
      )

    assert {:error, %Error{status: 429, retry_after: nil, rate_limit: %{remaining: 95}}} =
             Client.request(limited_client(sequence([too_many_exports])), @operation)

    refute_received {:slept, _ms}
    assert_requested()
    refute_received {:castor_edc_request, _request}
  end

  test "tells how many seconds are left on a 429" do
    reset = DateTime.utc_now() |> DateTime.shift(minute: 2) |> DateTime.to_unix() |> Integer.to_string()
    response = json(%{}, status: 429, headers: %{"x-ratelimit-retry-after" => [reset]})

    assert {:error, %Error{retry_after: seconds}} =
             Client.request(limited_client(response, rate_limit: :error), @operation)

    assert seconds in 118..120
  end

  test "rejects an unknown rate_limit mode" do
    assert_raise ArgumentError, ~r/:rate_limit/, fn -> client(json(%{}), rate_limit: :ignore) end
  end
end

defmodule CastorEDC.RateLimitThrottleTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client
  alias CastorEDC.Error

  @operation [method: :get, path: "/api/study/{study_id}/field", path_params: %{"study_id" => "S"}, query_names: %{}]
  @now 1_791_399_700

  setup do
    {:ok, clock} = Agent.start_link(fn -> @now end)
    %{base_url: "https://test-#{System.unique_integer([:positive])}.invalid", clock: clock}
  end

  defp used_up(reset_in) do
    json(%{},
      headers: %{
        "x-ratelimit-limit" => ["600"],
        "x-ratelimit-remaining" => ["0"],
        "x-ratelimit-retry-after" => [Integer.to_string(@now + reset_in)]
      }
    )
  end

  defp throttled_client(response, %{base_url: base_url, clock: clock}, options \\ []) do
    test = self()

    response
    |> client(Keyword.put(options, :base_url, base_url))
    |> Req.Request.put_private(:castor_edc_clock, fn -> Agent.get(clock, & &1) end)
    |> Req.Request.put_private(:castor_edc_sleep, fn ms -> send(test, {:slept, ms}) end)
  end

  test "waits for the window to reset when the last response said nothing is left", context do
    Client.request(throttled_client(used_up(20), context), @operation)
    assert_requested()

    assert {:ok, _body} = Client.request(throttled_client(json(%{}), context), @operation)

    assert_received {:slept, ms}
    assert ms in 20_001..20_250
    assert_requested()
  end

  test "reports each wait as a telemetry event", context do
    ref = :telemetry_test.attach_event_handlers(self(), [[:castor_edc, :rate_limit, :wait]])

    Client.request(throttled_client(used_up(5), context), @operation)
    Client.request(throttled_client(json(%{}), context), @operation)

    assert_received {[:castor_edc, :rate_limit, :wait], ^ref, %{duration: duration}, metadata}
    assert duration in 5_001..5_250
    assert metadata == %{bucket: "/api/study/{study_id}/field", base_url: context.base_url}
  end

  test "doesn't wait once the window has reset", context do
    Client.request(throttled_client(used_up(20), context), @operation)
    Agent.update(context.clock, &(&1 + 21))

    assert {:ok, _body} = Client.request(throttled_client(json(%{}), context), @operation)
    refute_received {:slept, _ms}
  end

  test "doesn't send a request it knows would be refused with rate_limit: :error", context do
    Client.request(throttled_client(used_up(20), context), @operation)
    assert_requested()

    assert {:error, %Error{code: :rate_limited, status: 429, retry_after: 20, rate_limit: %{remaining: 0}}} =
             Client.request(throttled_client(json(%{}), context, rate_limit: :error), @operation)

    refute_received {:castor_edc_request, _request}
    refute_received {:slept, _ms}
  end

  test "doesn't wait longer than max_rate_limit_wait", context do
    Client.request(throttled_client(used_up(90), context), @operation)

    assert {:error, %Error{code: :rate_limited, retry_after: 90}} =
             Client.request(throttled_client(json(%{}), context, max_rate_limit_wait: 60_000), @operation)
  end

  test "only holds back the bucket that's used up", context do
    Client.request(throttled_client(used_up(20), context), @operation)

    visits = Keyword.put(@operation, :path, "/api/study/{study_id}/visit")
    assert {:ok, _body} = Client.request(throttled_client(json(%{}), context), visits)
    refute_received {:slept, _ms}
  end
end
