defmodule CastorEDC.Test do
  @moduledoc """
  A client for tests, whose responses the test writes and whose requests it
  can inspect.

  `client/2` builds a client from `CastorEDC.new/1` whose Req adapter never
  touches the network: it answers with the response the test gives and
  sends the request it would have made to the test process, where
  `requested/1` reads it back. Because only the adapter is replaced, every
  request and response step still runs, including authentication, rate
  limiting and decoding into structs.

      client = CastorEDC.Test.client(CastorEDC.Test.json(%{"study_id" => "S1"}))
      {:ok, study} = CastorEDC.Studies.get_study(client, "S1")

      request = CastorEDC.Test.requested()
      assert request.url.path == "/api/study/S1"

  A function answers each request in turn, which suits operations that page:

      client =
        CastorEDC.Test.client(fn request ->
          case request.url.path do
            "/api/study/S1/site" -> CastorEDC.Test.json(sites)
            "/api/study/S1/participant" -> CastorEDC.Test.json(participants)
          end
        end)
  """

  defmodule Adapter do
    @moduledoc false

    def run(request) do
      {owner, responder} = Req.Request.get_private(request, :castor_edc_stub)
      send(owner, {:castor_edc_request, request})

      {request, responder.(request)}
    end
  end

  @doc """
  A client that answers every request with `response`.

  `response` is a `Req.Response`, an exception, or a function that takes the
  `Req.Request` and returns one of those. Retries are off and an access token
  is set, unless `options` says otherwise; the options go to
  `CastorEDC.new/1`.

  The requests go to the process that built the client.
  """
  @spec client(Req.Response.t() | Exception.t() | (Req.Request.t() -> Req.Response.t() | Exception.t()), keyword()) ::
          Req.Request.t()
  def client(response, options \\ []) do
    responder = if is_function(response, 1), do: response, else: fn _request -> response end

    options =
      if Keyword.has_key?(options, :client_id), do: options, else: Keyword.put_new(options, :access_token, "test-token")

    [retry: false, adapter: Adapter]
    |> Keyword.merge(options)
    |> CastorEDC.new()
    |> Req.Request.put_private(:castor_edc_stub, {self(), responder})
  end

  @doc """
  A JSON response with the given status, 200 by default, and headers.

      iex> response = CastorEDC.Test.json(%{"id" => 1}, status: 201)
      iex> {response.status, response.body}
      {201, ~s({"id":1})}
  """
  @spec json(term(), keyword()) :: Req.Response.t()
  def json(body, options \\ []) do
    [status: options[:status] || 200, headers: options[:headers] || %{}]
    |> Req.Response.new()
    |> Req.Response.json(body)
  end

  @doc """
  The next request a `client/2` client sent, or `nil` when none arrives
  within `timeout` milliseconds.
  """
  @spec requested(timeout()) :: Req.Request.t() | nil
  def requested(timeout \\ 100) do
    receive do
      {:castor_edc_request, request} -> request
    after
      timeout -> nil
    end
  end
end
