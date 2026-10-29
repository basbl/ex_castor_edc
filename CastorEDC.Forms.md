# `CastorEDC.Forms`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/forms.ex#L4)

The forms of a study and the visits that group them.

## Operations

  * `get_form/4` - Retrieve a single Form
  * `get_visit/4` - Retrieve a single Visit
  * `list_forms/3` - Retrieve list of available forms
  * `list_visits/3` - Retrieve list of available visits

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_form`

```elixir
@spec get_form(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Form.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Form.

Sends `GET /api/study/{study_id}/form/{form_id}`. [API reference](https://data.castoredc.com/api#/form/get_study__study_id__form__form_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `form_id` - ID of the form to fetch

Every option is passed to `Req`.

# `get_form!`

```elixir
@spec get_form!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Form.t()
```

The same as `get_form/4`, returning the result or raising `CastorEDC.Error`.

# `get_visit`

```elixir
@spec get_visit(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Visit.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Visit.

Sends `GET /api/study/{study_id}/visit/{visit_id}`. [API reference](https://data.castoredc.com/api#/visit/get_study__study_id__visit__visit_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `visit_id` - Visit ID of the visit to fetch

Every option is passed to `Req`.

# `get_visit!`

```elixir
@spec get_visit!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Visit.t()
```

The same as `get_visit/4`, returning the result or raising `CastorEDC.Error`.

# `list_forms`

```elixir
@spec list_forms(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Form.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available forms.

Gets `Form` objects, which are Forms that are collected only once per participant.
Forms are placed in a Visit and contain Fields.

Sends `GET /api/study/{study_id}/form`. [API reference](https://data.castoredc.com/api#/form/get_study__study_id__form)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Form.t/0` records.

# `list_forms!`

```elixir
@spec list_forms!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Form.t())
```

The same as `list_forms/3`, returning the result or raising `CastorEDC.Error`.

# `list_visits`

```elixir
@spec list_visits(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Visit.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available visits.

Gets `Visit` objects.

Sends `GET /api/study/{study_id}/visit`. [API reference](https://data.castoredc.com/api#/visit/get_study__study_id__visit)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Visit.t/0` records.

# `list_visits!`

```elixir
@spec list_visits!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Visit.t())
```

The same as `list_visits/3`, returning the result or raising `CastorEDC.Error`.

# `stream_forms`

```elixir
@spec stream_forms(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Form.t())
```

Streams every record `list_forms/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_visits`

```elixir
@spec stream_visits(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Visit.t())
```

Streams every record `list_visits/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
