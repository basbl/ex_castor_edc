# `CastorEDC.Client`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/client.ex#L1)

Runs the operations of the API.

The generated modules (`CastorEDC.Participants` and the rest) describe
each operation, from its path to the struct its response decodes into,
and hand that description to this module's `request/2`, which isn't part
of the public API: the description's format may change in any release.
This module does everything
that's the same for all of them: building the URL, sending the
caller's options under the names the API knows them by, unwrapping
collections into `CastorEDC.Page`s, decoding responses into structs, and
turning failures into `CastorEDC.Error`s.

Build the client these functions take with `CastorEDC.new/1`.

## Telemetry

Every operation is wrapped in a `[:castor_edc, :request]` span:

  * `[:castor_edc, :request, :start]` - with `:method`, `:route` (the path
    template, such as `"/api/study/{study_id}/site"`, so metrics don't get a
    series per study) and `:base_url` as metadata
  * `[:castor_edc, :request, :stop]` - with the `:duration`, and `:status`
    added to the metadata: `:ok`, or the error's HTTP status (`nil` when the
    request never got an answer) together with the `:error`
  * `[:castor_edc, :request, :exception]` - when something raised

Retries and token requests happen within the span.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
