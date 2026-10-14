# `CastorEDC.Sites`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/sites.ex#L4)

The sites of a study.

## Operations

  * `create_site/4` - Creates a site
  * `get_site/4` - Retrieve a single Site
  * `list_sites/3` - Retrieve list of study sites

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_site`

```elixir
@spec create_site(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.SiteCollection.t()} | {:error, CastorEDC.Error.t()}
```

Creates a site.

Creates `Site` objects.

Sends `POST /api/study/{study_id}/site`. [API reference](https://data.castoredc.com/api#/site/post_study__study_id__site)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `body` - a map, sent as JSON: **Sites** to be created: **name** of the Site, **abbreviation** of the Site (between 2 and 6 characters), **code** of the Site, max 3 characters long, **country_id** of the Site.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `create_site!`

```elixir
@spec create_site!(CastorEDC.client(), String.t(), map(), keyword()) ::
  CastorEDC.Model.SiteCollection.t()
```

The same as `create_site/4`, returning the result or raising `CastorEDC.Error`.

# `get_site`

```elixir
@spec get_site(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Site.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Site.

Sends `GET /api/study/{study_id}/site/{site_id}`. [API reference](https://data.castoredc.com/api#/site/get_study__study_id__site__site_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `site_id` - Site ID of the Site to fetch

Every option is passed to `Req`.

# `get_site!`

```elixir
@spec get_site!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Site.t()
```

The same as `get_site/4`, returning the result or raising `CastorEDC.Error`.

# `list_sites`

```elixir
@spec list_sites(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Site.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of study sites.

Gets `Site` objects.

Sends `GET /api/study/{study_id}/site`. [API reference](https://data.castoredc.com/api#/site/get_study__study_id__site)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Site.t/0` records.

# `list_sites!`

```elixir
@spec list_sites!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Site.t())
```

The same as `list_sites/3`, returning the result or raising `CastorEDC.Error`.

# `stream_sites`

```elixir
@spec stream_sites(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Site.t())
```

Streams every record `list_sites/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
