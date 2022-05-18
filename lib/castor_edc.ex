defmodule CastorEDC do
  @moduledoc """
  Acts as a wrapper for HTTPoison and provides convenience functions
  to perform HTTP requests.
  """

  use HTTPoison.Base
  alias CastorEDC.Client
  alias Jason

  def authenticate(%Client{} = client) do
    {200, body, _} =
      raw_request(
        :post,
        url(client, "oauth/token"),
        URI.encode_query(%{
          client_id: client.client_id,
          client_secret: client.client_secret,
          grant_type: client.grant_type,
          scope: client.scope
        }),
        %{"Content-Type" => "application/x-www-form-urlencoded"}
      )

    token = body["access_token"]

    Client.put_token(client, token)
  end

  def post(path, client, body \\ "") do
    _request(:post, url(client, path), client.access_token, Jason.encode!(body))
  end

  def get(path, client, params \\ []) do
    url =
      url(client, path)
      |> add_params_to_url(params)

    _request(
      :get,
      url,
      client.access_token
    )
  end

  defp _request(method, url, auth, body \\ "") do
    request!(
      method,
      url,
      body,
      %{
        "Accept" => "application/json",
        "Authorization" => "Bearer " <> auth,
        "Content-Type" => "application/json"
      }
    )
    |> process_response()
  end

  def raw_request(method, url, body \\ "", headers \\ [], _options \\ []) do
    method
    |> request!(url, body, headers)
    |> process_response
  end

  defp add_params_to_url(url, params) do
    url
    |> URI.parse()
    |> merge_uri_params(params)
    |> String.Chars.to_string()
  end

  defp merge_uri_params(uri, []), do: uri

  defp merge_uri_params(%URI{query: nil} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.put(:query, URI.encode_query(params))
  end

  defp merge_uri_params(%URI{} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.update!(:query, fn q ->
      q
      |> URI.decode_query()
      |> Map.merge(param_list_to_map_with_string_keys(params))
      |> URI.encode_query()
    end)
  end

  defp param_list_to_map_with_string_keys(list) when is_list(list) or is_map(list) do
    for {key, value} <- list, into: Map.new() do
      {"#{key}", value}
    end
  end

  def process_response_body(""), do: nil
  def process_response_body(body), do: Jason.decode!(body)

  def process_response(%HTTPoison.Response{status_code: status_code, body: body} = resp),
    do: {status_code, body, resp}

  def process_response({_status_code, _, %HTTPoison.Response{} = resp}),
    do: process_response(resp)

  defp url(%Client{endpoint: endpoint}, path), do: endpoint <> path
end
