defmodule CastorEDC do
  @moduledoc ~S"""
  An Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

  Every call takes a client, built by `new/1` from your API credentials:

      client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")

  The client is a `Req.Request`; see `new/1` for the options.
  """

  alias CastorEDC.Auth.Secret

  @default_base_url "https://data.castoredc.com"
  @missing_credentials """
  no Castor EDC credentials found.

  Pass them to CastorEDC.new/1:

      CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")

  configure them once:

      config :ex_castor_edc,
        client_id: System.fetch_env!("CASTOR_EDC_CLIENT_ID"),
        client_secret: System.fetch_env!("CASTOR_EDC_CLIENT_SECRET")

  or set the CASTOR_EDC_CLIENT_ID and CASTOR_EDC_CLIENT_SECRET environment variables.
  """
  @user_agent "ex_castor_edc/" <> Mix.Project.config()[:version]

  # The API's times without a zone are local to the server; each of Castor
  # EDC's public servers has one fixed zone.
  @time_zones %{
    "data.castoredc.com" => "Europe/Amsterdam",
    "uk.castoredc.com" => "Europe/London",
    "us.castoredc.com" => "America/New_York",
    "au.castoredc.com" => "Australia/Sydney"
  }

  @typedoc """
  A client from `new/1`, or the options to build one with.
  """
  @type client :: Req.Request.t() | keyword()

  @doc """
  Builds a client.

  ## Options

    * `:client_id` and `:client_secret` - your API credentials, exchanged
      for access tokens as needed (see `CastorEDC.Auth`). They default
      to the `:client_id` and `:client_secret` application environment keys,
      then to the `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET`
      environment variables.
    * `:access_token` - a token to send as is instead, such as a Castor
      Identity token. No credentials are needed then.
    * `:base_url` - the Castor EDC server: the `:base_url` application
      environment key, then the `CASTOR_EDC_BASE_URL` environment variable,
      then `#{@default_base_url}`. Studies in other regions live on other
      servers, such as `https://us.castoredc.com`.
    * `:rate_limit` - `:wait` (the default) to wait out the API's rate
      limit, or `:error` to get the 429 back right away; see
      `CastorEDC.RateLimit`.
    * `:max_rate_limit_wait` - the longest to wait for a rate limit, in
      milliseconds, 60 seconds by default.
    * `:time_zone` - the server's time zone, which the API's times without
      a zone are local to (see `time_zone/1`): the `:time_zone` application
      environment key, then the `CASTOR_EDC_TIME_ZONE` environment variable,
      then the zone of Castor EDC's public servers (`Europe/Amsterdam` for
      data.castoredc.com, `Europe/London` for uk, `America/New_York` for us
      and `Australia/Sydney` for au). Set it for a private server.

  Every other option is passed to `Req.new/1`, so timeouts, retries and
  connection options are set the same way:

      CastorEDC.new(client_id: id, client_secret: secret, receive_timeout: 30_000)

  Like Req by default, the client retries GET and HEAD requests that fail
  for a passing reason (a timeout, a closed connection, a 408 or a 5xx),
  but not a 429, which `CastorEDC.RateLimit` handles; pass `retry:` to
  change that.

  Requests go over HTTP/2, which every Castor EDC server speaks, so
  concurrent requests share one connection instead of opening one each.
  To use HTTP/1 instead, for a proxy that doesn't speak HTTP/2 for
  example, pass `connect_options: [protocols: [:http1]]`. More concurrent
  connections come from Finch's `:count` pool option, through `finch: [count: n]`.

  Raises `ArgumentError` when it finds neither credentials nor an access
  token.
  """
  @spec new(keyword()) :: Req.Request.t()
  def new(options \\ []) do
    {own, req_options} =
      Keyword.split(options, [
        :client_id,
        :client_secret,
        :access_token,
        :base_url,
        :rate_limit,
        :max_rate_limit_wait,
        :time_zone
      ])

    base_url = setting(own, :base_url, "CASTOR_EDC_BASE_URL")
    base_url = if present?(base_url), do: base_url, else: @default_base_url

    [
      base_url: base_url,
      user_agent: @user_agent,
      retry: &CastorEDC.RateLimit.retry?/2
    ]
    |> Keyword.merge(http2(req_options))
    |> Req.new()
    |> CastorEDC.RateLimit.attach(Keyword.take(own, [:rate_limit, :max_rate_limit_wait]))
    |> authenticate_with(credentials!(own))
    |> Req.Request.put_private(:castor_edc_time_zone, time_zone!(own, base_url))
  end

  @doc """
  The time zone of the client's server, which the API's times without a
  zone (such as a data point's `updated_on`, or a study's `created_on`)
  are local to: `Europe/Amsterdam` for data.castoredc.com, for example.
  `nil` for a server whose zone isn't known: set `:time_zone` in `new/1`.

      iex> CastorEDC.time_zone(CastorEDC.new(access_token: "t", base_url: "https://uk.castoredc.com"))
      "Europe/London"

  Turn such a time into a `DateTime` with it:

      DateTime.from_naive!(updated_on, CastorEDC.time_zone(client), Tz.TimeZoneDatabase)
  """
  @spec time_zone(client()) :: String.t() | nil
  def time_zone(client) when is_list(client), do: client |> new() |> time_zone()
  def time_zone(%Req.Request{} = client), do: Req.Request.get_private(client, :castor_edc_time_zone)

  defp time_zone!(own, base_url) do
    zone = setting(own, :time_zone, "CASTOR_EDC_TIME_ZONE")
    zone = if present?(zone), do: zone, else: Map.get(@time_zones, URI.parse(base_url).host)

    case zone && DateTime.now(zone, Tz.TimeZoneDatabase) do
      {:error, _reason} -> raise ArgumentError, "unknown time zone #{inspect(zone)} given as :time_zone"
      _known_or_nil -> zone
    end
  end

  # Multiplex over HTTP/2 unless told otherwise. Req takes the protocols from
  # :connect_options, or from :finch when that holds pool options; it can't
  # have both, and a named Finch pool is configured where it's started.
  defp http2(options) do
    case Keyword.fetch(options, :finch) do
      {:ok, finch} when is_list(finch) ->
        if Keyword.has_key?(finch, :name),
          do: options,
          else: Keyword.put(options, :finch, Keyword.put_new(finch, :protocols, [:http2]))

      {:ok, _named_pool} ->
        options

      :error ->
        Keyword.update(options, :connect_options, [protocols: [:http2]], &Keyword.put_new(&1, :protocols, [:http2]))
    end
  end

  defp credentials!(own) do
    token = own[:access_token]
    client_id = setting(own, :client_id, "CASTOR_EDC_CLIENT_ID")
    client_secret = setting(own, :client_secret, "CASTOR_EDC_CLIENT_SECRET")

    cond do
      present?(token) ->
        {:access_token, token}

      present?(client_id) and present?(client_secret) ->
        {:client_credentials, client_id, Secret.new(client_secret)}

      true ->
        raise ArgumentError, @missing_credentials
    end
  end

  # An option, then the application environment, then an environment variable.
  defp setting(own, key, variable), do: own[key] || configured(key) || System.get_env(variable)

  defp authenticate_with(request, {:access_token, token}) do
    Req.Request.put_header(request, "authorization", "Bearer " <> token)
  end

  defp authenticate_with(request, {:client_credentials, _client_id, _client_secret} = credentials) do
    request
    |> Req.Request.put_private(:castor_edc_credentials, credentials)
    |> CastorEDC.Auth.attach()
  end

  defp configured(key), do: Application.get_env(:ex_castor_edc, key)

  defp present?(value), do: is_binary(value) and value != ""
end
