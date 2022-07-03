defmodule CastorEDC.Client do
  @moduledoc ~S"""
  Container for API client configuration values.

  If you plan to use https://data.castoredc.com/ as an endpoint then you can use `new/2`

      client = Client.new("<client id>", "<client secret>")

  When your study is located in a different region then you can use `new/3`

      client = Client.new("<client id>", "<client secret>", "https://<domain>/")

  The clients can then be passed to `CastorEDC.authenticate/1` for an access token.

  Depending on whether you have a long-lived access token you can use either `access_token/1` or `access_token/2`
  and pass in an access token directly allowing you to skip the authentication step.

        client = Client.access_token("<access token>")

  """
  alias __MODULE__

  @default_user_agent "elixir-ex_castor_edc/" <> Mix.Project.config()[:version]

  @type url() :: String.t()
  @type uuid() :: String.t()

  @type t() :: %__MODULE__{
          client_id: nil | uuid(),
          client_secret: nil | String.t(),
          grant_type: String.t(),
          scope: String.t(),
          endpoint: url(),
          access_token: nil | String.t(),
          user_agent: String.t()
        }

  defstruct client_id: nil,
            client_secret: nil,
            grant_type: "client_credentials",
            scope: "default",
            endpoint: "https://data.castoredc.com/",
            access_token: nil,
            user_agent: @default_user_agent

  @doc """
  You can get your client id and secret from the account settings page after logging in
  over at https://data.castoredc.com/ or the region that your studies reside at.

      client = Client.new("<client id>", "<client secret>")

  Use `new/3` if your studies are hosted, for example, in the US.

      client = Client.new("<client id>", "<client secret>", "https://us.castoredc.com/")
  """
  @spec new(uuid(), String.t()) :: Client.t()
  @spec new(uuid(), String.t(), url()) :: Client.t()
  def new(client_id, client_secret),
    do: %__MODULE__{client_id: client_id, client_secret: client_secret}

  def new(client_id, client_secret, endpoint),
    do: %__MODULE__{client_id: client_id, client_secret: client_secret, endpoint: endpoint}

  @doc ~S"""
  If you already have an access token you can use this function to pass it in directly allowing
  you to skip the authentication step.

      client = Client.access_token("<access token>")

  or `access_token/2` when your studies are hosted, for example, in Australia

      client = Client.access_token("<access token>", "https://au.castoredc.com/")
  """
  @spec access_token(String.t()) :: Client.t()
  @spec access_token(String.t(), url()) :: Client.t()
  def access_token(access_token),
    do: %__MODULE__{access_token: access_token}

  def access_token(access_token, endpoint),
    do: %__MODULE__{access_token: access_token, endpoint: endpoint}

  @doc """
  This is an internal function that will add the access token after the authentication step.
  """
  @spec put_token(Client.t(), String.t()) :: Client.t()
  def put_token(client, access_token), do: %__MODULE__{client | access_token: access_token}
end
