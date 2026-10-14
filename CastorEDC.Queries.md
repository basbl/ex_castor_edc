# `CastorEDC.Queries`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/queries.ex#L4)

Queries raised on a study's data.

## Operations

  * `get_query/4` - Retrieve a single Query
  * `list_queries/3` - Retrieve list of study queries

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_query`

```elixir
@spec get_query(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Query.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Query.

Sends `GET /api/study/{study_id}/query/{query_id}`. [API reference](https://data.castoredc.com/api#/query/get_study__study_id__query__query_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `query_id` - Record ID of the Query to fetch

Every option is passed to `Req`.

# `get_query!`

```elixir
@spec get_query!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Query.t()
```

The same as `get_query/4`, returning the result or raising `CastorEDC.Error`.

# `list_queries`

```elixir
@spec list_queries(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Query.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of study queries.

Gets `Query` objects.

Sends `GET /api/study/{study_id}/query`. [API reference](https://data.castoredc.com/api#/query/get_study__study_id__query)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Query.t/0` records.

# `list_queries!`

```elixir
@spec list_queries!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Query.t())
```

The same as `list_queries/3`, returning the result or raising `CastorEDC.Error`.

# `stream_queries`

```elixir
@spec stream_queries(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Query.t())
```

Streams every record `list_queries/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
