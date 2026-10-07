defmodule CastorEDC.AuthTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Client
  alias CastorEDC.Error

  @operation [method: :get, path: "/api/study", query_names: %{}]

  # Every test gets its own server, so the shared token cache doesn't leak
  # between tests, and its own clock, so expiry needs no sleeping.
  setup do
    {:ok, clock} = Agent.start_link(fn -> 1_000_000 end)
    %{base_url: "https://test-#{System.unique_integer([:positive])}.invalid", clock: clock}
  end

  defp credentials_client(responder, %{base_url: base_url, clock: clock}, options \\ []) do
    responder
    |> client(Keyword.merge([client_id: "id", client_secret: "secret", base_url: base_url], options))
    |> Req.Request.put_private(:castor_edc_clock, fn -> Agent.get(clock, & &1) end)
  end

  # Answers token requests with a numbered token and API requests with the
  # token they carried, counting both.
  defp api(test_pid, options \\ []) do
    tokens = :counters.new(1, [])

    fn request ->
      case request.url.path do
        "/oauth/token" ->
          :counters.add(tokens, 1, 1)
          send(test_pid, {:token_request, request})
          json(%{"access_token" => "token-#{:counters.get(tokens, 1)}", "expires_in" => 18_000, "token_type" => "Bearer"})

        _api ->
          answer_api(request, Keyword.get(options, :rejected, []))
      end
    end
  end

  defp answer_api(request, rejected) do
    [authorization] = Req.Request.get_header(request, "authorization")
    json(%{"authorization" => authorization}, status: if(authorization in rejected, do: 401, else: 200))
  end

  test "exchanges the client credentials for a token and sends it", context do
    client = credentials_client(api(self()), context)

    assert {:ok, %{"authorization" => "Bearer token-1"}} = Client.request(client, @operation)

    assert_received {:token_request, token_request}
    assert token_request.method == :post

    assert URI.decode_query(IO.iodata_to_binary(token_request.body)) == %{
             "client_id" => "id",
             "client_secret" => "secret",
             "grant_type" => "client_credentials",
             "scope" => "default"
           }
  end

  test "reuses a cached token until it's about to expire", context do
    client = credentials_client(api(self()), context)

    assert {:ok, %{"authorization" => "Bearer token-1"}} = Client.request(client, @operation)
    assert {:ok, %{"authorization" => "Bearer token-1"}} = Client.request(client, @operation)
    assert_received {:token_request, _request}
    refute_received {:token_request, _request}

    # Tokens last 18,000 seconds; within a minute of that, a new one is fetched.
    Agent.update(context.clock, &(&1 + 18_000 - 59))

    assert {:ok, %{"authorization" => "Bearer token-2"}} = Client.request(client, @operation)
  end

  test "shares tokens between clients with the same credentials and server only", context do
    responder = api(self())

    assert {:ok, %{"authorization" => "Bearer token-1"}} =
             Client.request(credentials_client(responder, context), @operation)

    assert {:ok, %{"authorization" => "Bearer token-1"}} =
             Client.request(credentials_client(responder, context), @operation)

    other = credentials_client(responder, context, client_id: "other-id")
    assert {:ok, %{"authorization" => "Bearer token-2"}} = Client.request(other, @operation)
  end

  test "fetches a new token and retries once when the API answers 401", context do
    client = credentials_client(api(self(), rejected: ["Bearer token-1"]), context)

    assert {:ok, %{"authorization" => "Bearer token-2"}} = Client.request(client, @operation)
    assert {:ok, %{"authorization" => "Bearer token-2"}} = Client.request(client, @operation)
  end

  test "returns the second 401 instead of retrying again", context do
    client = credentials_client(api(self(), rejected: ["Bearer token-1", "Bearer token-2"]), context)

    assert {:error, %Error{status: 401}} = Client.request(client, @operation)
  end

  test "explains the SSO login rule when the token endpoint answers 403", context do
    responder = fn _request ->
      json(%{"success" => false, "reason" => "User has not logged in recently."}, status: 403)
    end

    assert {:error, %Error{status: 403, code: :login_required, message: message}} =
             Client.request(credentials_client(responder, context), @operation)

    assert message =~ "User has not logged in recently."
    assert message =~ "at least every seven days"
  end

  test "reports any other refused token request", context do
    responder = fn _request -> json(%{"error_description" => "Invalid client"}, status: 400) end

    assert {:error, %Error{status: 400, message: "the token request was refused: " <> _rest}} =
             Client.request(credentials_client(responder, context), @operation)
  end

  test "reports a token request that never arrived", context do
    responder = fn _request -> %Req.TransportError{reason: :nxdomain} end

    assert {:error, %Error{status: nil, reason: %Req.TransportError{reason: :nxdomain}}} =
             Client.request(credentials_client(responder, context), @operation)
  end

  test "leaves clients with an access token alone" do
    client = client(fn request -> json(%{"authorization" => Req.Request.get_header(request, "authorization")}) end)

    assert {:ok, %{"authorization" => ["Bearer test-token"]}} = Client.request(client, @operation)
  end
end
