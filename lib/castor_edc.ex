defmodule CastorEDC do
  @moduledoc ~S"""
  An Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

  Every call takes a client, built by `new/1` from your API credentials:

      client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")

  The client is a `Req.Request`; see `new/1` for the options.
  """

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
    * `:base_url` - the Castor EDC server, `#{@default_base_url}` by
      default. Studies in other regions live on other servers, such as
      `https://us.castoredc.com`.
    * `:rate_limit` - `:wait` (the default) to wait out the API's rate
      limit, or `:error` to get the 429 back right away; see
      `CastorEDC.RateLimit`.
    * `:max_rate_limit_wait` - the longest to wait for a rate limit, in
      milliseconds, 60 seconds by default.

  Every other option is passed to `Req.new/1`, so timeouts, retries and
  connection options are set the same way:

      CastorEDC.new(client_id: id, client_secret: secret, receive_timeout: 30_000)

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
      Keyword.split(options, [:client_id, :client_secret, :access_token, :base_url, :rate_limit, :max_rate_limit_wait])

    [base_url: own[:base_url] || configured(:base_url) || @default_base_url, user_agent: @user_agent]
    |> Keyword.merge(http2(req_options))
    |> Req.new()
    |> CastorEDC.RateLimit.attach(Keyword.take(own, [:rate_limit, :max_rate_limit_wait]))
    |> authenticate_with(credentials!(own))
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
      present?(token) -> {:access_token, token}
      present?(client_id) and present?(client_secret) -> {:client_credentials, client_id, client_secret}
      true -> raise ArgumentError, @missing_credentials
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
