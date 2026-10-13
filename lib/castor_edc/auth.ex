defmodule CastorEDC.Auth do
  @moduledoc """
  Gets and keeps access tokens for clients built from client credentials.

  `CastorEDC.new/1` attaches this to every client it builds from a client
  ID and secret, so nobody has to fetch a token by hand:

    * Before a request, it takes a token from `POST /oauth/token` with the
      client credentials grant, unless one is cached that's valid for at
      least another minute. Tokens last five hours, and the API issues no
      refresh token for this grant, so an expired one is simply replaced.
    * Tokens are cached per server and credentials (the client ID and a hash
      of the secret), so every process using the same credentials shares
      them, and a client with the right ID but another secret never gets
      another client's token. Two processes that miss the cache at the
      same moment may both fetch one, which is harmless: every token stays
      valid until it expires.
    * When the API answers 401 anyway, the cached token is dropped and the
      request sent once more with a new one.

  A token request the API refuses becomes a `CastorEDC.Error`. Accounts
  that sign in through SSO or Castor Identity get a 403 from the token
  endpoint until they've logged in to the Castor EDC web application in
  the last seven days; that error has `code: :login_required`.
  """

  alias CastorEDC.Auth.Secret
  alias CastorEDC.Error

  @table :castor_edc_tokens
  @leeway 60

  @doc false
  @spec attach(Req.Request.t()) :: Req.Request.t()
  def attach(request) do
    request
    |> Req.Request.append_request_steps(castor_edc_auth: &authenticate/1)
    |> Req.Request.prepend_response_steps(castor_edc_reauthenticate: &reauthenticate/1)
  end

  @doc false
  def authenticate(request) do
    credentials = Req.Request.get_private(request, :castor_edc_credentials)
    key = key(request, credentials)

    case cached(key, now(request)) do
      {:ok, token} -> bearer(request, token)
      :none -> fetch_and_cache(request, key, credentials)
    end
  end

  defp fetch_and_cache(request, key, credentials) do
    case fetch_token(request, credentials) do
      {:ok, token, expires_in} ->
        :ets.insert(@table, {key, token, now(request) + expires_in})
        bearer(request, token)

      {:error, error} ->
        {request, error}
    end
  end

  @doc false
  def reauthenticate({request, %Req.Response{status: 401} = response}) do
    if Req.Request.get_private(request, :castor_edc_reauthenticated) do
      {request, response}
    else
      :ets.delete(@table, key(request, Req.Request.get_private(request, :castor_edc_credentials)))

      {request, response_or_exception} =
        request
        |> Req.Request.put_private(:castor_edc_reauthenticated, true)
        |> Map.put(:halted, false)
        |> Req.Request.run_request()

      Req.Request.halt(request, response_or_exception)
    end
  end

  def reauthenticate(request_response), do: request_response

  # A digest of the secret, not the secret, so the table never holds it.
  defp key(request, {:client_credentials, client_id, %Secret{value: secret}}) do
    {request.options.base_url, client_id, :crypto.hash(:sha256, secret)}
  end

  defp cached(key, now) do
    case :ets.lookup(@table, key) do
      [{^key, token, expires_at}] when expires_at - @leeway > now -> {:ok, token}
      _missing_or_expiring -> :none
    end
  end

  defp bearer(request, token), do: Req.Request.put_header(request, "authorization", "Bearer " <> token)

  # The token request goes to the same server, through the same adapter and
  # connection options as the request it's for, but without its steps.
  defp fetch_token(request, {:client_credentials, client_id, %Secret{value: client_secret}}) do
    token_request =
      [
        method: :post,
        base_url: request.options.base_url,
        url: "/oauth/token",
        form: [client_id: client_id, client_secret: client_secret, grant_type: "client_credentials", scope: "default"],
        headers: [accept: "application/json"],
        user_agent: request.options[:user_agent],
        retry: false,
        adapter: request.adapter
      ]
      |> Req.new()
      |> Req.merge(
        request.options
        |> Map.take([:connect_options, :finch, :receive_timeout, :pool_timeout, :inet6])
        |> Enum.to_list()
      )
      |> Map.put(:private, Map.delete(request.private, :castor_edc_credentials))

    case Req.request(token_request) do
      {:ok, %Req.Response{status: 200, body: %{"access_token" => token} = body}} ->
        {:ok, token, Map.get(body, "expires_in", 3600)}

      {:ok, %Req.Response{status: 403, body: %{"reason" => reason}} = response} ->
        error = Error.from_response(response)

        {:error,
         %{
           error
           | code: :login_required,
             message:
               "the token request was refused: #{reason} Accounts that sign in through SSO or " <>
                 "Castor Identity have to log in to the Castor EDC web application at least every seven days."
         }}

      {:ok, %Req.Response{} = response} ->
        error = Error.from_response(response)
        {:error, %{error | message: "the token request was refused: " <> error.message}}

      {:error, exception} ->
        {:error, Error.from_exception(exception)}
    end
  end

  defp now(request) do
    case Req.Request.get_private(request, :castor_edc_clock) do
      nil -> System.os_time(:second)
      clock -> clock.()
    end
  end
end
