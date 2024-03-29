defmodule CastorEDCTest.Client do
  use ExUnit.Case

  import CastorEDC.Client

  @expect_user_agent "elixir-ex_castor_edc/" <> Mix.Project.config()[:version]

  test "creating a client with id and secret" do
    client = new(%{client_id: "client-id", client_secret: "client-secret"})

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://data.castoredc.com/"
  end

  test "creating a client with custom endpoint" do
    client =
      new(%{client_id: "client-id", client_secret: "client-secret"},
        endpoint: "https://us.castoredc.com"
      )

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://us.castoredc.com/"
  end

  test "creating a client with existing access token" do
    client = new(%{access_token: "access-token"})

    assert client.access_token == "access-token"
  end

  test "creating a client with existing access token and custom endpoint" do
    client = new(%{access_token: "access-token"}, endpoint: "https://us.castoredc.com")

    assert client.access_token == "access-token"
    assert client.endpoint == "https://us.castoredc.com/"
  end

  test "update_token/2" do
    client =
      new(%{client_id: "client-id", client_secret: "client-secret"},
        endpoint: "https://us.castoredc.com"
      )

    client = update_token(client, "access-token")

    assert client.client_id == "client-id"
    assert client.client_secret == "client-secret"
    assert client.endpoint == "https://us.castoredc.com/"
    assert client.access_token == "access-token"
  end

  test "set adapter_options options" do
    client =
      new(
        %{access_token: "access-token"},
        endpoint: "https://us.castoredc.com",
        adapter_options: [some_option: true],
        global_timeout: 30_000,
        adapter: Tesla.Adapter.Finch,
        user_agent: "some-user-agent"
      )

    assert client.access_token == "access-token"
    assert client.endpoint == "https://us.castoredc.com/"
    assert client.options[:global_timeout] == 30_000
    assert client.options[:user_agent] == "some-user-agent"
    assert client.options[:adapter] == Tesla.Adapter.Finch
    assert client.options[:adapter_options] == [some_option: true]
  end

  test "default options" do
    client =
      new(
        %{access_token: "access-token"},
        endpoint: "https://us.castoredc.com"
      )

    assert client.access_token == "access-token"
    assert client.endpoint == "https://us.castoredc.com/"
    assert client.options[:global_timeout] == 5_000
    assert client.options[:user_agent] == @expect_user_agent
    assert client.options[:adapter] == Tesla.Adapter.Hackney
    assert client.options[:adapter_options] == []
  end

  test "raises an error on unknown option" do
    assert_raise ArgumentError, fn ->
      new(
        %{access_token: "access-token"},
        endpoint: "https://us.castoredc.com/",
        unsupported_option: 30_000
      )
    end
  end
end
