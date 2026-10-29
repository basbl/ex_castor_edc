# `CastorEDC`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc.ex#L1)

An Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

Every call takes a client, built by `new/1` from your API credentials:

    client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")

The client is a `Req.Request`; see `new/1` for the options.

# `client`

```elixir
@type client() :: Req.Request.t() | keyword()
```

A client from `new/1`, or the options to build one with.

# `new`

```elixir
@spec new(keyword()) :: Req.Request.t()
```

Builds a client.

## Options

  * `:client_id` and `:client_secret` - your API credentials, exchanged
    for access tokens as needed (see `CastorEDC.Auth`). They default
    to the `:client_id` and `:client_secret` application environment keys,
    then to the `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET`
    environment variables.
  * `:access_token` - a token to send as is instead, such as a Castor
    Identity token. No credentials are needed then.
  * `:base_url` - the Castor EDC server: the `:base_url` application
    environment key, then the `CASTOR_EDC_BASE_URL` environment variable,
    then `https://data.castoredc.com`. Studies in other regions live on other
    servers, such as `https://us.castoredc.com`.
  * `:rate_limit` - `:wait` (the default) to wait out the API's rate
    limit, or `:error` to get the 429 back right away; see
    `CastorEDC.RateLimit`.
  * `:max_rate_limit_wait` - the longest to wait for a rate limit, in
    milliseconds, 60 seconds by default.
  * `:time_zone` - the server's time zone, which the API's times without
    a zone are local to (see `time_zone/1`): the `:time_zone` application
    environment key, then the `CASTOR_EDC_TIME_ZONE` environment variable,
    then the zone of Castor EDC's public servers (`Europe/Amsterdam` for
    data.castoredc.com, `Europe/London` for uk, `America/New_York` for us
    and `Australia/Sydney` for au). Set it for a private server.

Every other option is passed to `Req.new/1`, so timeouts, retries and
connection options are set the same way:

    CastorEDC.new(client_id: id, client_secret: secret, receive_timeout: 30_000)

Like Req by default, the client retries GET and HEAD requests that fail
for a passing reason (a timeout, a closed connection, a 408 or a 5xx),
but not a 429, which `CastorEDC.RateLimit` handles; pass `retry:` to
change that.

Requests go over HTTP/2, which every Castor EDC server speaks, so
concurrent requests share one connection instead of opening one each.
To use HTTP/1 instead, for a proxy that doesn't speak HTTP/2 for
example, pass `connect_options: [protocols: [:http1]]`. More concurrent
connections come from Finch's `:count` pool option, through `finch: [count: n]`.

Raises `ArgumentError` when it finds neither credentials nor an access
token.

# `time_zone`

```elixir
@spec time_zone(client()) :: String.t() | nil
```

The time zone of the client's server, which the API's times without a
zone (such as a data point's `updated_on`, or a study's `created_on`)
are local to: `Europe/Amsterdam` for data.castoredc.com, for example.
`nil` for a server whose zone isn't known: set `:time_zone` in `new/1`.

    iex> CastorEDC.time_zone(CastorEDC.new(access_token: "t", base_url: "https://uk.castoredc.com"))
    "Europe/London"

Turn such a time into a `DateTime` with it:

    DateTime.from_naive!(updated_on, CastorEDC.time_zone(client), Tz.TimeZoneDatabase)

---

*Consult [api-reference.md](api-reference.md) for complete listing*
