# `CastorEDC.OptionGroups`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/option_groups.ex#L4)

The option groups behind radio, dropdown and checkbox fields.

## Operations

  * `get_option_group/4` - Retrieve a single FieldOptionGroup
  * `list_option_groups/3` - Retrieves the list of all available FieldOptionGroups

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_option_group`

```elixir
@spec get_option_group(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.FieldOptionGroup.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single FieldOptionGroup.

Sends `GET /api/study/{study_id}/field-optiongroup/{optiongroup_id}`. [API reference](https://data.castoredc.com/api#/field-optiongroup/get_study__study_id__field_optiongroup__optiongroup_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `option_group_id` - ID of the optiongroup to fetch

Every option is passed to `Req`.

# `get_option_group!`

```elixir
@spec get_option_group!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.FieldOptionGroup.t()
```

The same as `get_option_group/4`, returning the result or raising `CastorEDC.Error`.

# `list_option_groups`

```elixir
@spec list_option_groups(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.FieldOptionGroup.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves the list of all available FieldOptionGroups.

Gets `FieldOptionGroup` objects.

Sends `GET /api/study/{study_id}/field-optiongroup`. [API reference](https://data.castoredc.com/api#/field-optiongroup/get_study__study_id__field_optiongroup)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.FieldOptionGroup.t/0` records.

# `list_option_groups!`

```elixir
@spec list_option_groups!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.FieldOptionGroup.t())
```

The same as `list_option_groups/3`, returning the result or raising `CastorEDC.Error`.

# `stream_option_groups`

```elixir
@spec stream_option_groups(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.FieldOptionGroup.t())
```

Streams every record `list_option_groups/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
