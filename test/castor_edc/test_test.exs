defmodule CastorEDC.TestTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Model.Study
  alias CastorEDC.Test

  doctest Test

  test "answers with the response and hands over the request" do
    client = Test.client(Test.json(%{"study_id" => "S1"}))

    assert {:ok, %Study{study_id: "S1"}} = CastorEDC.Studies.get_study(client, "S1")
    assert Test.requested().url.path == "/api/study/S1"
    assert Test.requested(0) == nil
  end

  test "answers each request through a function" do
    client = Test.client(fn request -> Test.json(%{"study_id" => Path.basename(request.url.path)}) end)

    assert {:ok, %Study{study_id: "S2"}} = CastorEDC.Studies.get_study(client, "S2")
    assert %Req.Request{} = Test.requested()
  end

  test "authenticates when given credentials instead of a token" do
    client =
      Test.client(
        fn request ->
          if request.url.path == "/oauth/token",
            do: Test.json(%{"access_token" => "fetched", "expires_in" => 3600}),
            else: Test.json(%{"study_id" => "S3"})
        end,
        client_id: "id",
        client_secret: "secret",
        base_url: "https://test-test.example"
      )

    assert {:ok, _study} = CastorEDC.Studies.get_study(client, "S3")
    assert Test.requested().url.path == "/oauth/token"
  end
end
