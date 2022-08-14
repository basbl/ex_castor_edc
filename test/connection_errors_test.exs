defmodule CastorEDCTest.ConnectionErrors do
  use ExUnit.Case, async: true

  import CastorEDC

  @client CastorEDC.Client.new(
            %{access_token: "supersecretaccesstoken"},
            "https://data.castoredc.com/",
            adapter: Tesla.Mock
          )

  setup do
    # Intercept all requests to always return {:error, :econnrefused}
    #
    # For more information, see:
    #
    # - https://hexdocs.pm/tesla/Tesla.Mock.html
    Tesla.Mock.mock_global(fn _env ->
      {:error, :econnrefused}
    end)

    :ok
  end

  test "get" do
    {:error, :econnrefused} = get("api/", @client)
  end

  test "post" do
    {:error, :econnrefused} = post("api/", @client, %{})
  end

  test "patch" do
    {:error, :econnrefused} = patch("api/", @client, %{})
  end

  test "authenticate" do
    {:error, :econnrefused} = CastorEDC.authenticate(@client)
  end
end
