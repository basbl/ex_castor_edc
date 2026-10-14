# `CastorEDC.Verifications`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/verifications.ex#L4)

Verifications (such as source data verification) of a study's data.

## Operations

  * `list_verifications/3` - Retrieve list of study verifications

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `list_verifications`

```elixir
@spec list_verifications(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Verification.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of study verifications.

Gets `Verification` objects.

Sends `GET /api/study/{study_id}/verification`. [API reference](https://data.castoredc.com/api#/verification/get_study__study_id__verification)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:participant_id` (string) - Filter verifications based on record id
  * `:date_from` (string) - Filter verifications with verification date higher or equal than provided
  * `:date_to` (string) - Filter verifications with verification date lower or equal than provided
  * `:verification_type` (string) - Filter verifications based on a comma separated list of verification type ids
  * `:entity_type` (string) - Filter verifications based on a comma separated list of entity types. Valid values are 'report step', 'field', 'step'
  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Verification.t/0` records.

# `list_verifications!`

```elixir
@spec list_verifications!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Verification.t())
```

The same as `list_verifications/3`, returning the result or raising `CastorEDC.Error`.

# `stream_verifications`

```elixir
@spec stream_verifications(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Verification.t())
```

Streams every record `list_verifications/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
