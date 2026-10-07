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

  Before a request, the client checks its route. When the last response
  said nothing is left and the window hasn't reset yet, it waits for the
  reset (plus up to a quarter of a second, so waiting processes don't all
  fire at once) instead of sending a request the API would refuse. Each
  wait emits a `[:castor_edc, :rate_limit, :wait]` telemetry event, with
  the wait in milliseconds as `:duration` and the `:bucket` and `:base_url`
  as metadata.

  When the API answers 429 anyway (other processes or machines may share
  the allowance), the client waits until the window resets and sends the
  request again, at most three times, as long as the wait is within
  `:max_rate_limit_wait` (60 seconds by default). A 429 is refused before
  anything happens, so this is safe for any request. With
  `rate_limit: :error`, or when the wait would be longer, the client doesn't
  wait: a request it knows would be refused isn't sent and returns a
  `CastorEDC.Error` with `code: :rate_limited`, and a 429 is returned as
  is; either way the error's `retry_after` says how many seconds are left.
  Both options are given to `CastorEDC.new/1`.

  The client only knows what this node has seen. Several nodes sharing
  credentials still get the 429 handling.
  """

  @table :castor_edc_rate_limits
  @max_attempts 3
  @max_jitter 250
  @default_max_wait 60_000

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
  @spec attach(Req.Request.t(), keyword()) :: Req.Request.t()
  def attach(request, options \\ []) do
    mode = Keyword.get(options, :rate_limit, :wait)
    max_wait = Keyword.get(options, :max_rate_limit_wait, @default_max_wait)

    if mode not in [:wait, :error],
      do: raise(ArgumentError, "expected :rate_limit to be :wait or :error, got: #{inspect(mode)}")

    request
    |> Req.Request.put_private(:castor_edc_rate_limit, {mode, max_wait})
    |> Req.Request.prepend_request_steps(castor_edc_throttle: &throttle/1)
    |> Req.Request.prepend_response_steps(castor_edc_rate_limit: &record/1, castor_edc_rate_limit_retry: &retry/1)
  end

  @doc false
  def throttle(request) do
    with false <- Req.Request.get_private(request, :castor_edc_waited, false),
         %{remaining: 0, reset_at: %DateTime{} = reset_at} = rate_limit <- lookup(request),
         wait when wait > 0 <- DateTime.diff(reset_at, now(request), :millisecond) do
      {mode, max_wait} = Req.Request.get_private(request, :castor_edc_rate_limit, {:wait, @default_max_wait})

      if mode == :wait and wait <= max_wait do
        wait = wait + :rand.uniform(@max_jitter)

        :telemetry.execute([:castor_edc, :rate_limit, :wait], %{duration: wait}, %{
          bucket: request |> Req.Request.get_private(:castor_edc_route) |> bucket(),
          base_url: request.options[:base_url]
        })

        sleep(request, wait)
        request
      else
        Req.Request.halt(request, rate_limited(rate_limit, wait))
      end
    else
      _not_limited -> request
    end
  end

  defp rate_limited(rate_limit, wait) do
    seconds = div(wait + 999, 1000)

    %CastorEDC.Error{
      message: "the rate limit of this route is used up; it resets in #{seconds} seconds",
      code: :rate_limited,
      status: 429,
      retry_after: seconds,
      rate_limit: rate_limit
    }
  end

  @doc false
  def retry({request, %Req.Response{status: 429} = response}) do
    {mode, max_wait} = Req.Request.get_private(request, :castor_edc_rate_limit, {:wait, @default_max_wait})
    attempts = Req.Request.get_private(request, :castor_edc_rate_limit_attempts, 0)

    with :wait <- mode,
         true <- attempts < @max_attempts,
         %{reset_at: %DateTime{} = reset_at} <- parse(response),
         wait when wait <= max_wait <- max(DateTime.diff(reset_at, now(request), :millisecond), 0) do
      sleep(request, wait)

      {request, response_or_exception} =
        request
        |> Req.Request.put_private(:castor_edc_rate_limit_attempts, attempts + 1)
        |> Req.Request.put_private(:castor_edc_waited, true)
        |> Map.put(:halted, false)
        |> Req.Request.run_request()

      Req.Request.halt(request, response_or_exception)
    else
      _no_wait -> {request, response}
    end
  end

  def retry(request_response), do: request_response

  @doc false
  # Seconds until the window of a rate-limited response resets.
  @spec retry_after(Req.Response.t()) :: non_neg_integer() | nil
  def retry_after(response) do
    case parse(response) do
      %{reset_at: %DateTime{} = reset_at} -> max(DateTime.diff(reset_at, DateTime.utc_now(), :second), 0)
      _unknown -> nil
    end
  end

  defp now(request) do
    case Req.Request.get_private(request, :castor_edc_clock) do
      nil -> DateTime.utc_now()
      clock -> DateTime.from_unix!(clock.())
    end
  end

  defp sleep(request, milliseconds) do
    Req.Request.get_private(request, :castor_edc_sleep, &Process.sleep/1).(milliseconds)
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
