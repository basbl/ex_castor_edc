defmodule CastorEDC.Case do
  @moduledoc """
  A client whose responses the test writes, and whose requests it can inspect.

  `client/2` builds a client from `CastorEDC.new/1` whose Req adapter never
  touches the network: it answers with the response the test gives and
  sends the request it would have made to the test process, where
  `assert_requested/1` reads it back. Because only the adapter is replaced,
  every request and response step still runs, including authentication and
  rate limiting.
  """

  use ExUnit.CaseTemplate

  import ExUnit.Assertions

  defmodule Adapter do
    @moduledoc false

    def run(request) do
      {owner, responder} = Req.Request.get_private(request, :castor_edc_stub)
      send(owner, {:castor_edc_request, request})

      {request, responder.(request)}
    end
  end

  using do
    quote do
      import CastorEDC.Case
    end
  end

  @doc """
  A client that answers every request with `response`.

  `response` is a `Req.Response`, an exception, or a function that takes the
  `Req.Request` and returns one of those. Retries are off and an access token
  is set, unless `options` says otherwise; the options go to
  `CastorEDC.new/1`.
  """
  @spec client(term(), keyword()) :: Req.Request.t()
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
  """
  @spec json(term(), keyword()) :: Req.Response.t()
  def json(body, options \\ []) do
    [status: options[:status] || 200, headers: options[:headers] || %{}]
    |> Req.Response.new()
    |> Req.Response.json(body)
  end

  @doc """
  The decoded contents of `test/fixtures/<name>.json`.
  """
  @spec fixture(String.t()) :: term()
  def fixture(name) do
    "test/fixtures"
    |> Path.join(name <> ".json")
    |> File.read!()
    |> JSON.decode!()
  end

  @doc """
  The request the client sent, failing the test if there was none.
  """
  @spec assert_requested(timeout()) :: Req.Request.t()
  def assert_requested(timeout \\ 100) do
    assert_receive {:castor_edc_request, request}, timeout
    request
  end
end
