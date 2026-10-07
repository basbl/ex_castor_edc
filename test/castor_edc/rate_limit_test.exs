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
