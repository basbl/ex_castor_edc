defmodule CastorEDCTest.Client do
  use ExUnit.Case

  import CastorEDC.Client

  test "new/2" do
    client = new("client-id", "client-secret")

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://data.castoredc.com/"
  end

  test "new/3" do
    client = new("client-id", "client-secret", "https://us.castoredc.com")

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://us.castoredc.com"
  end

  test "access_token/1" do
    client = access_token("access-token")

    assert client.access_token == "access-token"
  end

  test "access_token/2" do
    client = access_token("access-token", "https://us.castoredc.com")

    assert client.access_token == "access-token"
    assert client.endpoint == "https://us.castoredc.com"
  end

  test "put_token/2" do
    client = new("client-id", "client-secret", "https://us.castoredc.com")
    client = put_token(client, "access-token")

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://us.castoredc.com"
    assert client.access_token == "access-token"
  end
end
