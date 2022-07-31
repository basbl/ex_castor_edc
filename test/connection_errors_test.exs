defmodule CastorEDCTest.ConnectionErrors do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup do
    Process.put(:mock_tesla_adapter, true)
    # Intercept all requests to always return {:error, :econnrefused}
    #
    # For more information, see:
    #
    # - https://hexdocs.pm/tesla/Tesla.Mock.html
    Tesla.Mock.mock(fn _env ->
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
    client =
      CastorEDC.Client.new(
        "0b362196-09ad-4d09-b5bf-27a515bbc358",
        "secret"
      )

    {:error, :econnrefused} = CastorEDC.authenticate(client)
  end
end
