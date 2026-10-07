defmodule CastorEDC.NewTest do
  # Not async: some tests change the application and OS environment.
  use ExUnit.Case, async: false

  setup do
    for key <- [:client_id, :client_secret, :base_url], do: Application.delete_env(:ex_castor_edc, key)
    previous = for name <- ~w(CASTOR_EDC_CLIENT_ID CASTOR_EDC_CLIENT_SECRET), do: {name, System.get_env(name)}
    for {name, _value} <- previous, do: System.delete_env(name)

    on_exit(fn ->
      for key <- [:client_id, :client_secret, :base_url], do: Application.delete_env(:ex_castor_edc, key)
      for {name, value} <- previous, value, do: System.put_env(name, value)
    end)
  end

  test "builds a Req request for data.castoredc.com from client credentials" do
    request = CastorEDC.new(client_id: "id", client_secret: "secret")

    assert %Req.Request{} = request
    assert request.options.base_url == "https://data.castoredc.com"
    assert request.options.user_agent == "ex_castor_edc/" <> Mix.Project.config()[:version]
    assert Req.Request.get_private(request, :castor_edc_credentials) == {:client_credentials, "id", "secret"}
    assert Req.Request.get_header(request, "authorization") == []
  end

  test "sends an access token as a bearer token, without needing credentials" do
    request = CastorEDC.new(access_token: "token")

    assert Req.Request.get_header(request, "authorization") == ["Bearer token"]
    assert Req.Request.get_private(request, :castor_edc_credentials) == nil
  end

  test "takes another server and passes every other option to Req" do
    request = CastorEDC.new(access_token: "token", base_url: "https://us.castoredc.com", receive_timeout: 30_000)

    assert request.options.base_url == "https://us.castoredc.com"
    assert request.options.receive_timeout == 30_000
  end

  test "multiplexes requests over HTTP/2 unless told otherwise" do
    assert CastorEDC.new(access_token: "token").options.connect_options == [protocols: [:http2]]

    assert CastorEDC.new(access_token: "token", connect_options: [timeout: 1000]).options.connect_options ==
             [protocols: [:http2], timeout: 1000]

    assert CastorEDC.new(access_token: "token", connect_options: [protocols: [:http1]]).options.connect_options ==
             [protocols: [:http1]]

    # Req can't take both :finch and :connect_options.
    request = CastorEDC.new(access_token: "token", finch: [count: 4])
    assert request.options.finch == [protocols: [:http2], count: 4]
    refute Map.has_key?(request.options, :connect_options)

    assert CastorEDC.new(access_token: "token", finch: [name: MyFinch]).options.finch == [name: MyFinch]
  end

  test "falls back to the application environment, then to environment variables" do
    Application.put_env(:ex_castor_edc, :client_id, "configured-id")
    System.put_env("CASTOR_EDC_CLIENT_SECRET", "env-secret")
    Application.put_env(:ex_castor_edc, :base_url, "https://uk.castoredc.com")

    request = CastorEDC.new()

    assert Req.Request.get_private(request, :castor_edc_credentials) ==
             {:client_credentials, "configured-id", "env-secret"}

    assert request.options.base_url == "https://uk.castoredc.com"
  end

  test "raises with instructions when there are no credentials" do
    error = assert_raise ArgumentError, fn -> CastorEDC.new(client_id: "id") end
    assert error.message =~ "no Castor EDC credentials found"
    assert error.message =~ "CASTOR_EDC_CLIENT_SECRET"

    assert_raise ArgumentError, fn -> CastorEDC.new(access_token: "") end
  end

  test "rejects options neither it nor Req knows" do
    assert_raise ArgumentError, ~r/unknown option :nope/, fn -> CastorEDC.new(access_token: "token", nope: 1) end
  end
end
