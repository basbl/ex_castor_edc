# `CastorEDC.Exports`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/exports.ex#L4)

Batch exports: queuing them, listing them with their status, and downloading the result. CastorEDC.Export does all three in one call.

## Operations

  * `download_export/4` - File download. Endpoint responds with binary stream.
  * `list_exports/3` - Shows the status of previously requested exports
  * `queue_exports/4` - Request exports of multiple types.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `download_export`

```elixir
@spec download_export(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, binary() | Collectable.t()} | {:error, CastorEDC.Error.t()}
```

File download. Endpoint responds with binary stream.

Sends `GET /api/study/{study_id}/export/{id}/download`. [API reference](https://data.castoredc.com/api#/export/get_study__study_id__export__id__download)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `export_id` - The ID of the Export to download

Every option is passed to `Req`. The file comes back as a binary, unless
`:into` collects it elsewhere: `into: File.stream!(path)` streams it to
disk, and the result is then the stream.

# `download_export!`

```elixir
@spec download_export!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  binary() | Collectable.t()
```

The same as `download_export/4`, returning the result or raising `CastorEDC.Error`.

# `list_exports`

```elixir
@spec list_exports(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.ExportEntry.t())}
  | {:error, CastorEDC.Error.t()}
```

Shows the status of previously requested exports.

Sends `GET /api/study/{study_id}/export`. [API reference](https://data.castoredc.com/api#/export/get_study__study_id__export)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `100`; a larger one is lowered to it) - The size of pages

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.ExportEntry.t/0` records.

# `list_exports!`

```elixir
@spec list_exports!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.ExportEntry.t())
```

The same as `list_exports/3`, returning the result or raising `CastorEDC.Error`.

# `queue_exports`

```elixir
@spec queue_exports(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.ExportSuccess.t()} | {:error, CastorEDC.Error.t()}
```

Request exports of multiple types.

This batch endpoint supports initiating multiple, distinct export types in a single request.

Sends `POST /api/study/{study_id}/export`. [API reference](https://data.castoredc.com/api#/default/post_study__study_id__export)

## Arguments

  * `study_id` - The ID of the study for which this call should be made.
  * `body` - a map, sent as JSON: Please note that this endpoint is currently in beta and implementation details may change. Export format, options, and filters depend on the export type. All filters are optional. Please find a description of some parameters below. - filters.participant_ids: **If provided, other filters will be skipped.** - queries.elements: Only one type at a time is supported, so provide either repeating_data, visits or visit_forms key. - survey_compliance.parent_id: Visit/Repeating data UUID. To demonstrate use of all supported ENUM values, following notation is used in request payload: **empty | visit | repeating_data** - meaning in this example, all three values are supported.
    * `exports` (object, required)

Every option is passed to `Req`.

# `queue_exports!`

```elixir
@spec queue_exports!(CastorEDC.client(), String.t(), map(), keyword()) ::
  CastorEDC.Model.ExportSuccess.t()
```

The same as `queue_exports/4`, returning the result or raising `CastorEDC.Error`.

# `stream_exports`

```elixir
@spec stream_exports(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.ExportEntry.t())
```

Streams every record `list_exports/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
