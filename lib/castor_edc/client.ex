defmodule CastorEDC.Client do
  @moduledoc """
  Container for authentication related values
  """

  defstruct client_id: nil,
            client_secret: nil,
            grant_type: "client_credentials",
            scope: "default",
            endpoint: "https://data.castoredc.com/",
            access_token: nil

  def new(client_id, client_secret),
    do: %__MODULE__{client_id: client_id, client_secret: client_secret}

  def new(client_id, client_secret, endpoint),
    do: %__MODULE__{client_id: client_id, client_secret: client_secret, endpoint: endpoint}

  def access_token(access_token),
    do: %__MODULE__{access_token: access_token}

  def access_token(access_token, endpoint),
    do: %__MODULE__{access_token: access_token, endpoint: endpoint}

  def put_token(client, access_token), do: %__MODULE__{client | access_token: access_token}
end
