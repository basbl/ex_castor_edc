defmodule CastorEDC.Client do
  @moduledoc ~S"""
  Container for API client configuration values.

  If you plan to use https://data.castoredc.com/ as an endpoint then you can simply pass
  in a map with your client id and secret.

      client = Client.new(%{client_id: "<client id>", client_secret: "<client secret>"})

  When your study is located in a different region then you can pass in the url as the second
  argument

      client = Client.new(%{client_id: "<client id>", client_secret: "<client secret>"}, "https://<domain>/")

  You can now call `CastorEDC.authenticate(client)`.

  Alternatively, when you have a long-lived access token you can pass it in directly

      client = Client.new(%{access_token: "<access token>"})

  Additionally it's possible to pass options e.g increasing the timeout.

      client = Client.new(
        %{client_id: "<client id>", client_secret: "<client secret>"},
        "https://us.castoredc.com/",
        timeout: 30_000
      )
  """
  alias __MODULE__

  @default_timeout 5_000

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

  @spec new(credentials(), url(), keyword()) :: Client.t()
  def new(credentials, endpoint \\ "https://data.castoredc.com/", opts \\ [])

  def new(%{client_id: client_id, client_secret: client_secret}, endpoint, opts)
      when is_binary(endpoint) do
    validate_options!(opts)

    %__MODULE__{
      client_id: client_id,
      client_secret: client_secret,
      endpoint: endpoint(endpoint),
      options: merge_options(opts)
    }
  end

  def new(%{access_token: access_token}, endpoint, opts) when is_binary(endpoint) do
    validate_options!(opts)

    %__MODULE__{
      access_token: access_token,
      endpoint: endpoint(endpoint),
      options: merge_options(opts)
    }
  end

  defp validate_options!(opts) do
    supported_options = [:adapter, :adapter_options, :timeout]

    options =
      supported_options
      |> Enum.map_join(", ", &inspect/1)

    for {option, _value} <- opts do
      if option not in supported_options do
        raise ArgumentError, "Unknown option, expected one of #{options}, got: #{inspect(option)}"
      end
    end
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

  @doc """
  This is an internal function that will add the access token after the authentication step.
  """
  def update_token(%Client{} = client, access_token),
    do: %__MODULE__{client | access_token: access_token}
end
