defmodule CastorEDC.RateLimit do
  @moduledoc """
  Keeps track of the API's rate limits.

  The API limits requests per user and per route, in fixed windows of ten
  minutes: 6,000 requests per route on data.castoredc.com, and fewer on
  some other servers. A route is a resource, so listing participants and
  fetching one draw from the same allowance. Every response says how much
  is left in these headers:

    * `X-RateLimit-Limit` - requests allowed in the window
    * `X-RateLimit-Remaining` - requests left in it
    * `X-RateLimit-Retry-After` - when the window resets, as a Unix
      timestamp (not a number of seconds, as `Retry-After` would be)

  The client records them for every route it uses, per server and
  credentials.
  """

  @table :castor_edc_rate_limits

  @type t :: %{limit: non_neg_integer() | nil, remaining: non_neg_integer() | nil, reset_at: DateTime.t() | nil}

  @doc """
  Reads the rate limit headers of a response, or returns `nil` when it has
  none.
  """
  @spec parse(Req.Response.t() | %{optional(String.t()) => [String.t()]}) :: t() | nil
  def parse(%Req.Response{headers: headers}), do: parse(headers)

  def parse(headers) when is_map(headers) do
    limit = header_integer(headers, "x-ratelimit-limit")
    remaining = header_integer(headers, "x-ratelimit-remaining")
    reset = header_integer(headers, "x-ratelimit-retry-after")

    if limit || remaining || reset do
      %{limit: limit, remaining: remaining, reset_at: reset && DateTime.from_unix!(reset)}
    end
  end

  @doc """
  The rate limit last recorded for the route of `request`, or `nil`.
  """
  @spec lookup(Req.Request.t()) :: t() | nil
  def lookup(request) do
    with key when key != nil <- key(request),
         [{^key, rate_limit}] <- :ets.lookup(@table, key) do
      rate_limit
    else
      _unknown -> nil
    end
  end

  @doc false
  @spec attach(Req.Request.t()) :: Req.Request.t()
  def attach(request) do
    Req.Request.prepend_response_steps(request, castor_edc_rate_limit: &record/1)
  end

  @doc false
  def record({request, %Req.Response{} = response}) do
    with key when key != nil <- key(request),
         %{} = rate_limit <- parse(response) do
      :ets.insert(@table, {key, rate_limit})
    end

    {request, response}
  end

  @doc """
  The bucket an operation's requests count against: its path template
  without a trailing parameter, so a collection and its items share one.

      iex> CastorEDC.RateLimit.bucket("/api/study/{study_id}/field/{field_id}")
      "/api/study/{study_id}/field"
      iex> CastorEDC.RateLimit.bucket("/api/study/{study_id}/field")
      "/api/study/{study_id}/field"
  """
  @spec bucket(String.t()) :: String.t()
  def bucket(route), do: String.replace(route, ~r"/\{[^}/]+\}$", "")

  # Requests made through CastorEDC.Client carry their route. The
  # credentials are the client ID, or a digest of the access token.
  defp key(request) do
    case Req.Request.get_private(request, :castor_edc_route) do
      nil -> nil
      route -> {request.options[:base_url], credential(request), bucket(route)}
    end
  end

  defp credential(request) do
    case Req.Request.get_private(request, :castor_edc_credentials) do
      {:client_credentials, client_id, _secret} ->
        client_id

      nil ->
        request
        |> Req.Request.get_header("authorization")
        |> List.first("")
        |> then(&:crypto.hash(:sha256, &1))
    end
  end

  defp header_integer(headers, name) do
    with [value | _rest] <- Map.get(headers, name, []),
         {integer, ""} <- Integer.parse(value) do
      integer
    else
      _missing -> nil
    end
  end
end
