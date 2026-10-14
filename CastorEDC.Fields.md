# `CastorEDC.Fields`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/fields.ex#L4)

The fields of a study, with their dependencies and validations.

## Operations

  * `get_field/4` - Retrieve a single Field
  * `get_field_dependency/4` - Retrieve a single dependency
  * `get_field_validation/4` - Retrieve a single field-validation
  * `list_field_dependencies/3` - Retrieve list of available fieldDependency
  * `list_field_validations/3` - Retrieve list of available field-validations
  * `list_fields/3` - Retrieves the list of all available fields

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_field`

```elixir
@spec get_field(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Field.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Field.

Sends `GET /api/study/{study_id}/field/{field_id}`. [API reference](https://data.castoredc.com/api#/field/get_study__study_id__field__field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `field_id` - Field ID of the field to fetch

## Options

  * `:include` (list of string, sent comma-separated) - The extra properties to include in the Field array. Currently it supports 'metadata', 'validations', 'optiongroup', 'dependencies'. List separated by ','. Use like: ?include=metadata,validations,optiongroup. Separation by '|' is deprecated and will be removed in the next major release.

Any other option is passed to `Req`.

# `get_field!`

```elixir
@spec get_field!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Field.t()
```

The same as `get_field/4`, returning the result or raising `CastorEDC.Error`.

# `get_field_dependency`

```elixir
@spec get_field_dependency(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.FieldDependency.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single dependency.

Sends `GET /api/study/{study_id}/field-dependency/{fieldDependency_id}`. [API reference](https://data.castoredc.com/api#/field-dependency/get_study__study_id__field_dependency__fieldDependency_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `field_dependency_id` - ID of the fieldDependency to fetch

Every option is passed to `Req`.

# `get_field_dependency!`

```elixir
@spec get_field_dependency!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.FieldDependency.t()
```

The same as `get_field_dependency/4`, returning the result or raising `CastorEDC.Error`.

# `get_field_validation`

```elixir
@spec get_field_validation(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.FieldValidation.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single field-validation.

Sends `GET /api/study/{study_id}/field-validation/{fieldValidation_id}`. [API reference](https://data.castoredc.com/api#/field-validation/get_study__study_id__field_validation__fieldValidation_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `field_validation_id` - ID of the field-validation to fetch

Every option is passed to `Req`.

# `get_field_validation!`

```elixir
@spec get_field_validation!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.FieldValidation.t()
```

The same as `get_field_validation/4`, returning the result or raising `CastorEDC.Error`.

# `list_field_dependencies`

```elixir
@spec list_field_dependencies(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.FieldDependency.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available fieldDependency.

Gets `FieldDependency` objects.

Sends `GET /api/study/{study_id}/field-dependency`. [API reference](https://data.castoredc.com/api#/field-dependency/get_study__study_id__field_dependency)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.FieldDependency.t/0` records.

# `list_field_dependencies!`

```elixir
@spec list_field_dependencies!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.FieldDependency.t())
```

The same as `list_field_dependencies/3`, returning the result or raising `CastorEDC.Error`.

# `list_field_validations`

```elixir
@spec list_field_validations(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.FieldValidation.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available field-validations.

Gets `FieldValidation` objects.

Use the `include_referenced_field` query parameter to control field-to-field validations:
- When `false` (default): Only value-based validations are returned for backward compatibility
- When `true`: All validations including field-to-field validations are returned

Sends `GET /api/study/{study_id}/field-validation`. [API reference](https://data.castoredc.com/api#/field-validation/get_study__study_id__field_validation)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:include_referenced_field` (boolean, defaults to `false`) - Include validations with referenced field. When false (default), only value-based validations are returned. (Deprecated: check API changelog for more information)
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.FieldValidation.t/0` records.

# `list_field_validations!`

```elixir
@spec list_field_validations!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.FieldValidation.t())
```

The same as `list_field_validations/3`, returning the result or raising `CastorEDC.Error`.

# `list_fields`

```elixir
@spec list_fields(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Field.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves the list of all available fields.

Gets `Field` objects.

Sends `GET /api/study/{study_id}/field`. [API reference](https://data.castoredc.com/api#/field/get_study__study_id__field)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:include` (list of string, sent comma-separated) - The extra properties to include in the Field array. Currently it supports 'metadata', 'validations', 'optiongroup', 'dependencies'. List separated by ','. Use like: ?include=metadata,validations,optiongroup. Separation by '|' is deprecated and will be removed in the next major release.
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Field.t/0` records.

# `list_fields!`

```elixir
@spec list_fields!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Field.t())
```

The same as `list_fields/3`, returning the result or raising `CastorEDC.Error`.

# `stream_field_dependencies`

```elixir
@spec stream_field_dependencies(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.FieldDependency.t())
```

Streams every record `list_field_dependencies/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_field_validations`

```elixir
@spec stream_field_validations(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.FieldValidation.t())
```

Streams every record `list_field_validations/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_fields`

```elixir
@spec stream_fields(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Field.t())
```

Streams every record `list_fields/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
