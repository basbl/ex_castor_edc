# `CastorEDC.Metadata`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/metadata.ex#L4)

Metadata attached to a study's elements, and the types of metadata.

## Operations

  * `get_metadata/4` - Retrieve a single metadata item
  * `get_metadata_type/4` - Retrieve a single metadatatype
  * `list_metadata/3` - Retrieve list of available metadata
  * `list_metadata_types/3` - Retrieve list of available metadatatypes

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_metadata`

```elixir
@spec get_metadata(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Metadata.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single metadata item.

Sends `GET /api/study/{study_id}/metadata/{metadata_id}`. [API reference](https://data.castoredc.com/api#/metadata/get_study__study_id__metadata__metadata_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `metadata_id` - ID of the metadata to fetch

Every option is passed to `Req`.

# `get_metadata!`

```elixir
@spec get_metadata!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Metadata.t()
```

The same as `get_metadata/4`, returning the result or raising `CastorEDC.Error`.

# `get_metadata_type`

```elixir
@spec get_metadata_type(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.MetadataType.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single metadatatype.

Sends `GET /api/study/{study_id}/metadatatype/{metadatatype_id}`. [API reference](https://data.castoredc.com/api#/metadatatype/get_study__study_id__metadatatype__metadatatype_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `metadata_type_id` - ID of the metadatatype to fetch

Every option is passed to `Req`.

# `get_metadata_type!`

```elixir
@spec get_metadata_type!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.MetadataType.t()
```

The same as `get_metadata_type/4`, returning the result or raising `CastorEDC.Error`.

# `list_metadata`

```elixir
@spec list_metadata(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Metadata.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available metadata.

Gets `Metadata` objects.

Sends `GET /api/study/{study_id}/metadata`. [API reference](https://data.castoredc.com/api#/metadata/get_study__study_id__metadata)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Metadata.t/0` records.

# `list_metadata!`

```elixir
@spec list_metadata!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Metadata.t())
```

The same as `list_metadata/3`, returning the result or raising `CastorEDC.Error`.

# `list_metadata_types`

```elixir
@spec list_metadata_types(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.MetadataType.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available metadatatypes.

Gets `MetadataType` objects.

Sends `GET /api/study/{study_id}/metadatatype`. [API reference](https://data.castoredc.com/api#/metadatatype/get_study__study_id__metadatatype)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.MetadataType.t/0` records.

# `list_metadata_types!`

```elixir
@spec list_metadata_types!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.MetadataType.t())
```

The same as `list_metadata_types/3`, returning the result or raising `CastorEDC.Error`.

# `stream_metadata`

```elixir
@spec stream_metadata(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Metadata.t())
```

Streams every record `list_metadata/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_metadata_types`

```elixir
@spec stream_metadata_types(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.MetadataType.t())
```

Streams every record `list_metadata_types/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
