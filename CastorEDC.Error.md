# `CastorEDC.Error`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/error.ex#L1)

A failed request: one the API refused, one that never got an answer, or
one the client gave up on.

Every operation returns `{:error, %CastorEDC.Error{}}` rather than raising,
and the `!` variants raise it. A refused request has the HTTP `status`. A
request that failed in transit has a `nil` status and the underlying
exception in `reason`. An error the client makes itself has an atom
`code` (see below), and a status only when a response caused it.

The API answers errors with several kinds of body: an RFC 7807 problem
from inside an endpoint (with validation messages for some), and
`{"success": false, "errors": [...]}` or `{"success": false, "reason": ...}`
from the layers in front of it, such as rate limiting. Whichever arrives,
the useful parts end up in the same fields:

  * `message` - what went wrong, in a sentence
  * `code` - the API's error code, such as `"CODE_QUOTA_EXCEEDED"`, when
    it gives one, or an atom for errors the client recognises itself
  * `details` - each individual error the API reported, as
    `%{code:, message:, field:}` maps (`field` is set for validation
    messages and for values a bulk write didn't save)
  * `request_id` - a reference Castor support can trace
  * `retry_after` - on a 429, the seconds until the rate limit resets
  * `rate_limit` - the rate limit the response reported, see
    `CastorEDC.RateLimit.parse/1`
  * `body` and `headers` - the response as it arrived
  * `export_ids` - for the export errors, the IDs of the exports concerned
  * `result` - for some of the client's own errors, what it had when it
    gave up (see below)

The client's own codes:

  * `:login_required` - the token endpoint refused an account that signs
    in through SSO or Castor Identity (see `CastorEDC.Auth`)
  * `:rate_limited` - the rate limit is used up and the client didn't wait
    (see `CastorEDC.RateLimit`)
  * `:not_saved` - a bulk write answered 201 but didn't save everything;
    only the `!` variants return it, with what was saved and what wasn't
    in `result`, and each failure in `details`
  * `:too_many_exports` - the API refused another batch export while too
    many run
  * `:export_failed`, `:export_expired`, `:export_not_ready` - the export
    in `result` failed, expired, or isn't ready to download
  * `:export_timeout` - the exports in `export_ids` weren't ready in time;
    they keep running, and `result` holds them as last seen
  * `:export_not_found` - the study's export list has no export with an ID
    in `export_ids`
  * `:unzip_failed` - the export in `result` couldn't be unzipped; `reason`
    says why

# `t`

```elixir
@type t() :: %CastorEDC.Error{
  __exception__: term(),
  body: term(),
  code: String.t() | atom() | nil,
  details: [
    %{
      code: String.t() | nil,
      message: String.t() | nil,
      field: String.t() | nil
    }
  ],
  export_ids: [String.t()],
  headers: %{optional(String.t()) =&gt; [String.t()]} | nil,
  message: String.t(),
  rate_limit: map() | nil,
  reason: term(),
  request_id: String.t() | nil,
  result: term(),
  retry_after: non_neg_integer() | nil,
  status: 100..599 | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
