defmodule CastorEDC.Client do
  @moduledoc ~S"""
  Container for API client configuration values.
  """
  alias __MODULE__

  @supported_options [:adapter, :adapter_options, :global_timeout, :endpoint, :user_agent]

  @default_options endpoint: "https://data.castoredc.com/",
                   user_agent: "elixir-ex_castor_edc/" <> Mix.Project.config()[:version],
                   global_timeout: 5_000,
                   adapter: Tesla.Adapter.Hackney,
                   adapter_options: []

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

  Additionally it's possible to pass options e.g increasing the global_timeout.

      client = Client.new(
        %{client_id: "<client id>", client_secret: "<client secret>"},
        global_timeout: 30_000
      )

  ## Options
    * `:endpoint` - An alternative endpoint e.g. https://us.castoredc.com/
    * `:global_timeout` - The global_timeout in milliseconds, by default it is 5000
    * `:adapter` - Any module that implements the `Tesla.Adapter` behavior
    * `:adapter_options` - The supported options for the given adapter
  """
  @spec new(credentials(), keyword()) :: Client.t()
  def new(credentials, opts \\ [])

  def new(%{client_id: client_id, client_secret: client_secret}, opts) do
    validate_options!(opts)
    merge_properties(%{client_id: client_id, client_secret: client_secret}, opts)
  end

  def new(%{access_token: access_token}, opts) do
    validate_options!(opts)
    merge_properties(%{access_token: access_token}, opts)
  end

  defp validate_options!(opts) do
    options =
      @supported_options
      |> Enum.map_join(", ", &inspect/1)

    for {option, _value} <- opts do
      if option not in @supported_options do
        raise ArgumentError, "Unknown option, expected one of #{options}, got: #{inspect(option)}"
      end
    end
  end

  defp merge_properties(credentials, opts) do
    opts = merge_options(opts)
    endpoint = endpoint(opts[:endpoint])

    opts =
      opts
      |> Keyword.drop([:endpoint])

    %__MODULE__{endpoint: endpoint, options: opts}
    |> Map.merge(credentials)
  end

  defp merge_options(opts), do: Keyword.merge(@default_options, opts)

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
