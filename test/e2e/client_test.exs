defmodule CastorEDC.E2E.ClientTest do
  @moduledoc """
  The client's own behaviour against the API: tokens, rate limits and page
  sizes.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.Fields
  alias CastorEDC.Page
  alias CastorEDC.RateLimit
  alias CastorEDC.Studies

  test "fetches a token and keeps track of the rate limit", %{client: client, study: study} do
    assert {:ok, _study} = Studies.get_study(client, study)

    {_request, response} =
      client
      |> Req.Request.put_private(:castor_edc_route, "/api/study/{study_id}")
      |> Req.merge(url: "/api/study/#{study}")
      |> Req.Request.run_request()

    assert %{limit: limit, remaining: remaining, reset_at: %DateTime{}} = RateLimit.parse(response)
    assert remaining < limit
  end

  test "lowers a page size the API would refuse", %{client: client, study: study} do
    assert {:ok, %Page{page_size: 1000}} = Fields.list_fields(client, study, page_size: 100_000)
  end

  test "rejects bad credentials with an error" do
    client = CastorEDC.TestStudy.client(client_id: "nope", client_secret: "nope")

    # The token endpoint answers an unknown client with a 404.
    assert {:error, %CastorEDC.Error{status: status, message: "the token request was refused: " <> _reason}} =
             Studies.list_studies(client)

    assert status in 400..499
  end
end
