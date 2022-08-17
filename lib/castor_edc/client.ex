defmodule CastorEDC.Client do
  @moduledoc ~S"""
  Container for API client configuration values.
  """
  alias __MODULE__

  @default_timeout 5_000
  @default_endpoint "https://data.castoredc.com/"

  @type url() :: String.t()
  @type uuid() :: String.t()

  @type credentials :: %{client_id: binary, client_secret: binary} | %{access_token: binary}

  @type t() :: %__MODULE__{
          client_id: nil | uuid(),
          client_secret: nil | String.t(),
          grant_type: String.t(),
          scope: String.t(),
          endpoint: url(),
          access_token: nil | String.t(),
          options: []
        }

  defstruct client_id: nil,
            client_secret: nil,
            grant_type: "client_credentials",
            scope: "default",
            endpoint: nil,
            access_token: nil,
            options: []

  @doc """
  By default the client will use https://data.castoredc.com/ as the endpoint

      client = Client.new(%{client_id: "<client id>", client_secret: "<client secret>"})

  You can pass a different endpoint as an option when your studies are located elsewhere e.g.

      client = Client.new(
        %{client_id: "<client id>", client_secret: "<client secret>"},
        endpoint: "https://us.castoredc.com/"
      )

  Alternatively, when you have a long-lived access token you can pass it in directly

      client = Client.new(%{access_token: "<access token>"})

  Additionally it's possible to pass options e.g increasing the timeout.

      client = Client.new(
        %{client_id: "<client id>", client_secret: "<client secret>"},
        timeout: 30_000
      )

  ## Options
    * `:endpoint` - An alternative endpoint e.g. https://us.castoredc.com/
    * `:timeout` - The timeout in milliseconds, by default it is 5000
    * `:adapter` - Any module that implements the `Tesla.Adapter` behavior
    * `:adapter_options` - The supported options for the given adapter
  """
  @spec new(credentials(), keyword()) :: Client.t()
  def new(credentials, opts \\ [])

  def new(%{client_id: _, client_secret: _} = credentials, opts) do
    validate_options!(opts)
    merge_properties(credentials, opts)
  end

  def new(%{access_token: _} = credentials, opts) do
    validate_options!(opts)
    merge_properties(credentials, opts)
  end

  defp validate_options!(opts) do
    supported_options = [:adapter, :adapter_options, :timeout, :endpoint]

    options =
      supported_options
      |> Enum.map_join(", ", &inspect/1)

    for {option, _value} <- opts do
      if option not in supported_options do
        raise ArgumentError, "Unknown option, expected one of #{options}, got: #{inspect(option)}"
      end
    end
  end

  defp merge_properties(credentials, opts) do
    endpoint = endpoint(opts[:endpoint] || @default_endpoint)

    opts =
      opts
      |> Keyword.drop([:endpoint])

    %__MODULE__{endpoint: endpoint, options: merge_options(opts)}
    |> Map.merge(credentials)
  end

  defp merge_options(opts) do
    [
      timeout: opts[:timeout] || @default_timeout,
      adapter_options: opts[:adapter_options] || [],
      adapter: opts[:adapter] || Tesla.Adapter.Hackney
    ]
  end

  defp endpoint(endpoint) do
    if String.ends_with?(endpoint, "/") do
      endpoint
    else
      endpoint <> "/"
    end
  end

  @doc false
  def update_token(%Client{} = client, access_token),
    do: %__MODULE__{client | access_token: access_token}
end
