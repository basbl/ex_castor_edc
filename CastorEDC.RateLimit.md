# `CastorEDC.RateLimit`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/rate_limit.ex#L1)

Keeps track of the API's rate limits.

The API limits requests per user and per route, in fixed windows of ten
minutes: 6,000 requests per route on data.castoredc.com, and fewer on
some other servers. A route is a resource, so listing participants and
fetching one draw from the same allowance. Every response says how much
is left in these headers:

  * `X-RateLimit-Limit` - requests allowed in the window
  * `X-RateLimit-Remaining` - requests left in it
  * `X-RateLimit-Retry-After` - when the window resets, as a Unix
    timestamp (not a number of seconds, as `Retry-After` would be)

The client records them for every route it uses, per server and
credentials.

Before a request, the client checks its route. When the last response
said nothing is left and the window hasn't reset yet, it waits for the
reset (plus up to a quarter of a second, so waiting processes don't all
fire at once) instead of sending a request the API would refuse. Each
wait emits a `[:castor_edc, :rate_limit, :wait]` telemetry event, with
the wait in milliseconds as `:duration` and the `:bucket` and `:base_url`
as metadata.

When the API answers 429 anyway (other processes or machines may share
the allowance), the client waits until the window resets (plus the same
jitter) and sends the request again, at most three times, as long as the
wait is within
`:max_rate_limit_wait` (60 seconds by default). A 429 whose headers say
requests remain isn't about the rate limit (batch exports answer one when
too many run at once), and is returned as is. A 429 is refused before
anything happens, so this is safe for any request. With
`rate_limit: :error`, or when the wait would be longer, the client doesn't
wait: a request it knows would be refused isn't sent and returns a
`CastorEDC.Error` with `code: :rate_limited`, and a 429 is returned as
is; either way the error's `retry_after` says how many seconds are left.
Both options are given to `CastorEDC.new/1`.

The client only knows what this node has seen. Several nodes sharing
credentials still get the 429 handling.

# `t`

```elixir
@type t() :: %{
  limit: non_neg_integer() | nil,
  remaining: non_neg_integer() | nil,
  reset_at: DateTime.t() | nil
}
```

# `bucket`

```elixir
@spec bucket(String.t()) :: String.t()
```

The bucket an operation's requests count against: its path template
without a trailing parameter, so a collection and its items share one.

    iex> CastorEDC.RateLimit.bucket("/api/study/{study_id}/field/{field_id}")
    "/api/study/{study_id}/field"
    iex> CastorEDC.RateLimit.bucket("/api/study/{study_id}/field")
    "/api/study/{study_id}/field"

# `parse`

```elixir
@spec parse(Req.Response.t() | %{optional(String.t()) =&gt; [String.t()]}) :: t() | nil
```

Reads the rate limit headers of a response, or returns `nil` when it has
none.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
