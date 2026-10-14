# `CastorEDC.Test`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/test.ex#L1)

A client for tests, whose responses the test writes and whose requests it
can inspect.

`client/2` builds a client from `CastorEDC.new/1` whose Req adapter never
touches the network: it answers with the response the test gives and
sends the request it would have made to the test process, where
`requested/1` reads it back. Because only the adapter is replaced, every
request and response step still runs, including authentication, rate
limiting and decoding into structs.

    client = CastorEDC.Test.client(CastorEDC.Test.json(%{"study_id" => "S1"}))
    {:ok, study} = CastorEDC.Studies.get_study(client, "S1")

    request = CastorEDC.Test.requested()
    assert request.url.path == "/api/study/S1"

A function answers each request in turn, which suits operations that page:

    client =
      CastorEDC.Test.client(fn request ->
        case request.url.path do
          "/api/study/S1/site" -> CastorEDC.Test.json(sites)
          "/api/study/S1/participant" -> CastorEDC.Test.json(participants)
        end
      end)

# `client`

```elixir
@spec client(
  Req.Response.t()
  | Exception.t()
  | (Req.Request.t() -&gt; Req.Response.t() | Exception.t()),
  keyword()
) :: Req.Request.t()
```

A client that answers every request with `response`.

`response` is a `Req.Response`, an exception, or a function that takes the
`Req.Request` and returns one of those. Retries are off, an access token
is set and the server is `https://data.castoredc.com`, unless `options`
says otherwise; the options go to `CastorEDC.new/1`.

The requests go to the process that built the client.

# `json`

```elixir
@spec json(term(), keyword()) :: Req.Response.t()
```

A JSON response with the given status, 200 by default, and headers.

    iex> response = CastorEDC.Test.json(%{"id" => 1}, status: 201)
    iex> {response.status, response.body}
    {201, ~s({"id":1})}

# `requested`

```elixir
@spec requested(timeout()) :: Req.Request.t() | nil
```

The next request a `client/2` client sent, or `nil` when none arrives
within `timeout` milliseconds.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
