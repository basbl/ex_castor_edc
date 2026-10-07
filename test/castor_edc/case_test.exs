defmodule CastorEDC.CaseTest do
  use CastorEDC.Case, async: true

  test "answers with the given response and reports the request" do
    client = client(json(%{"name" => "Study"}))

    assert {:ok, %Req.Response{status: 200, body: %{"name" => "Study"}}} = Req.get(client, url: "/api/study/1")

    request = assert_requested()
    assert request.method == :get
    assert URI.to_string(request.url) == "https://data.castoredc.com/api/study/1"
    assert Req.Request.get_header(request, "authorization") == ["Bearer test-token"]
  end

  test "answers with a function of the request" do
    client = client(fn request -> json(%{"path" => request.url.path}, status: 201) end)

    assert {:ok, %Req.Response{status: 201, body: %{"path" => "/api/site"}}} = Req.post(client, url: "/api/site")
  end

  test "answers with an exception" do
    client = client(%Req.TransportError{reason: :timeout})

    assert {:error, %Req.TransportError{reason: :timeout}} = Req.get(client, url: "/api/study")
  end

  test "passes options on to CastorEDC.new/1" do
    client = client(json(%{}), base_url: "https://us.castoredc.com")

    Req.get!(client, url: "/api/study")
    assert assert_requested().url.host == "us.castoredc.com"
  end
end
