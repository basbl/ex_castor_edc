defmodule CastorEDC do
  @moduledoc ~S"""
  Acts as a wrapper for Tesla and provides convenience functions
  to perform HTTP requests.

      alias CastorEDC.Client

      client = Client.new("<client id>", "<client secret>")
      {:ok, client} = CastorEDC.authenticate(client)

  After authenticating against the API you can then use the other modules to perform
  API requests, e.g:

      {200, list_of_studies, _} = CastorEDC.Common.Studies.list(client)

      list_of_studies
  """

  alias CastorEDC.Client
  alias Jason

  @doc """
  Will exchange a valid combination of client id and secret into an access token. The access token
  can then be used to make further requests to the API
  """
  @spec authenticate(Client.t()) :: {:ok, Client.t()} | {:error, String.t()}
  def authenticate(%Client{} = client) do
    http_client([{Tesla.Middleware.FormUrlencoded, []}])
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

  @doc """
  Internal convenience function for POST requests
  """
  @spec post(String.t(), Client.t(), %{}) :: {integer(), %{}, Tesla.Env.t()}
  def post(url, %Client{} = client, body) do
    default_middleware(client)
    |> http_client()
    |> Tesla.post(url(client, url), body)
    |> handle_response()
  end

  @doc """
  Internal convenience function for PATCH requests
  """
  @spec patch(String.t(), Client.t(), %{}) :: {integer(), %{}, Tesla.Env.t()}
  def patch(url, %Client{} = client, body) do
    default_middleware(client)
    |> http_client()
    |> Tesla.patch(url(client, url), body)
    |> handle_response()
  end

  @doc """
  Internal convenience function for GET requests
  """
  @spec get(String.t(), Client.t(), []) :: {integer(), %{}, Tesla.Env.t()}
  def get(url, %Client{} = client, params \\ []) do
    default_middleware(client)
    |> http_client()
    |> Tesla.get(url(client, url), query: params)
    |> handle_response()
  end

  defp handle_authentication_response({:error, reason}, _client), do: {:error, reason}

  defp handle_authentication_response({:ok, %Tesla.Env{body: body, status: 200}}, client) do
    access_token = Jason.decode!(body)["access_token"]
    {:ok, Client.put_token(client, access_token)}
  end

  defp handle_authentication_response({_, %Tesla.Env{body: body}}, _) do
    error_description = Jason.decode!(body)["error_description"]
    {:error, error_description}
  end

  defp default_middleware(%Client{access_token: token}) do
    [
      {Tesla.Middleware.JSON, []},
      {Tesla.Middleware.BearerAuth, token: token},
      {Tesla.Middleware.Headers, [{"Accept", "application/json"}]}
    ]
  end

  defp http_client(middleware) do
    Tesla.client(middleware, {Tesla.Adapter.Hackney, []})
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
