defmodule CastorEDC do
  @moduledoc """
  Acts as a wrapper for HTTPoison and provides convenience functions
  to perform HTTP requests.
  """

  alias CastorEDC.Client
  alias Jason

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

  def post(url, %Client{} = client, body) do
    default_middleware(client)
    |> http_client()
    |> Tesla.post!(url(client, url), body)
    |> handle_response()
  end

  def get(url, %Client{} = client, params \\ []) do
    default_middleware(client)
    |> http_client()
    |> Tesla.get!(url(client, url), query: params)
    |> handle_response()
  end

  defp handle_authentication_response({_, %Tesla.Env{body: body, status: 200}}, client) do
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

  def process_response_body(""), do: nil
  def process_response_body(body) when is_binary(body), do: Jason.decode!(body)
  def process_response_body(body), do: body

  defp handle_response(%Tesla.Env{status: status, body: body} = response) do
    {status, process_response_body(body), response}
  end

  defp url(%Client{endpoint: endpoint}, path), do: endpoint <> path
end
