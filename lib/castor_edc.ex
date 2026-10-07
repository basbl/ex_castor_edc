defmodule CastorEDC do
  @moduledoc ~S"""
  An Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

  Every call takes a client, built by `new/1` from your API credentials:

      client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")

  The client is a `Req.Request`; see `new/1` for the options.

  ## Legacy API

  `authenticate/1`, together with `CastorEDC.Legacy.Client` and the modules
  under `CastorEDC.Common`, `CastorEDC.DataCollection` and
  `CastorEDC.StudyProtocol`, is the Tesla-based API of earlier versions. It
  goes away in 1.0:

      alias CastorEDC.Legacy.Client

      client = Client.new(%{client_id: "<client id>", client_secret: "<client secret>"})
      {:ok, client} = CastorEDC.authenticate(client)

      {200, list_of_studies, _} = CastorEDC.Common.Studies.list(client)
  """

  alias CastorEDC.Legacy.Client
  alias Tesla.Middleware.Headers

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

    * `:client_id` and `:client_secret` - your API credentials. They default
      to the `:client_id` and `:client_secret` application environment keys,
      then to the `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET`
      environment variables.
    * `:access_token` - a token to send as is instead, such as a Castor
      Identity token. No credentials are needed then.
    * `:base_url` - the Castor EDC server, `#{@default_base_url}` by
      default. Studies in other regions live on other servers, such as
      `https://us.castoredc.com`.

  Every other option is passed to `Req.new/1`, so timeouts, retries and
  connection options are set the same way:

      CastorEDC.new(client_id: id, client_secret: secret, receive_timeout: 30_000)

  Raises `ArgumentError` when it finds neither credentials nor an access
  token.
  """
  @spec new(keyword()) :: Req.Request.t()
  def new(options \\ []) do
    {own, req_options} = Keyword.split(options, [:client_id, :client_secret, :access_token, :base_url])

    [base_url: own[:base_url] || configured(:base_url) || @default_base_url, user_agent: @user_agent]
    |> Keyword.merge(req_options)
    |> Req.new()
    |> authenticate_with(credentials!(own))
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
    Req.Request.put_private(request, :castor_edc_credentials, credentials)
  end

  defp configured(key), do: Application.get_env(:ex_castor_edc, key)

  defp present?(value), do: is_binary(value) and value != ""

  @typedoc false
  @type response :: {integer(), term(), Tesla.Env.t()} | {:error, term()}

  @doc """
  Exchanges a valid client id & secret combination for an access token that can be used to
  make further API calls.
  """
  @spec authenticate(Client.t()) :: {:ok, Client.t()} | {:error, String.t()}
  def authenticate(%Client{options: opts} = client) do
    [
      {Tesla.Middleware.FormUrlencoded, []},
      {Tesla.Middleware.Opts, adapter: opts[:adapter_options]},
      {Headers, [{"User-Agent", opts[:user_agent]}]}
    ]
    |> http_client(client)
    |> Tesla.post(
      url(client, "oauth/token"),
      %{
        client_id: client.client_id,
        client_secret: client.client_secret,
        grant_type: client.grant_type,
        scope: client.scope
      }
    )
    |> handle_authentication_response(client)
  end

  @doc false
  @spec post(String.t(), Client.t(), map() | list() | Tesla.Multipart.t()) :: response()
  def post(url, %Client{} = client, body) do
    client
    |> default_middleware()
    |> http_client(client)
    |> Tesla.post(url(client, url), body)
    |> handle_response()
  end

  @doc false
  @spec patch(String.t(), Client.t(), map() | list()) :: response()
  def patch(url, %Client{} = client, body) do
    client
    |> default_middleware()
    |> http_client(client)
    |> Tesla.patch(url(client, url), body)
    |> handle_response()
  end

  @doc false
  @spec get(String.t(), Client.t(), keyword()) :: response()
  def get(url, %Client{} = client, params \\ []) do
    client
    |> default_middleware()
    |> http_client(client)
    |> Tesla.get(url(client, url), query: params)
    |> handle_response()
  end

  defp handle_authentication_response({:error, reason}, _client), do: {:error, reason}

  defp handle_authentication_response({:ok, %Tesla.Env{body: body, status: 200}}, client) do
    access_token = Jason.decode!(body)["access_token"]
    {:ok, Client.update_token(client, access_token)}
  end

  defp handle_authentication_response({_, %Tesla.Env{body: body}}, _) do
    error_description = Jason.decode!(body)["error_description"]
    {:error, error_description}
  end

  defp default_middleware(%Client{access_token: token, options: opts}) do
    middleware = [
      {Tesla.Middleware.JSON, []},
      {Tesla.Middleware.BearerAuth, token: token},
      {Headers, [{"Accept", "application/json"}, {"User-Agent", opts[:user_agent]}]}
    ]

    # If we're using the Tesla.Mock adapter we skip adding the timeout middleware
    # https://github.com/elixir-tesla/tesla/issues/157
    if opts[:adapter] === Tesla.Mock do
      middleware
    else
      [{Tesla.Middleware.Timeout, timeout: opts[:global_timeout]} | middleware]
    end
  end

  defp http_client(middleware, %Client{options: opts}) do
    Tesla.client(middleware, {opts[:adapter], opts[:adapter_options]})
  end

  defp process_response_body(""), do: nil
  defp process_response_body(body) when is_binary(body), do: Jason.decode!(body)
  defp process_response_body(body), do: body

  defp handle_response({:error, reason}), do: {:error, reason}

  defp handle_response({:ok, %Tesla.Env{status: status, body: body} = response}) do
    {status, process_response_body(body), response}
  end

  defp url(%Client{endpoint: endpoint}, path), do: endpoint <> path
end
