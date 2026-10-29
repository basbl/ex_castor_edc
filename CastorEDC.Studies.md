# `CastorEDC.Studies`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/studies.ex#L4)

The studies the credentials have access to, with their metadata and statistics.

## Operations

  * `get_study/3` - Retrieve a single Study
  * `get_study_statistics/3` - Retrieve statistics for a single Study 🔭
  * `list_studies/2` - Retrieve a list of studies the current authenticated user has access to.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_study`

```elixir
@spec get_study(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Study.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Study.

Sends `GET /api/study/{study_id}`. [API reference](https://data.castoredc.com/api#/study/get_study__study_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

Every option is passed to `Req`.

# `get_study!`

```elixir
@spec get_study!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Model.Study.t()
```

The same as `get_study/3`, returning the result or raising `CastorEDC.Error`.

# `get_study_statistics`

```elixir
@spec get_study_statistics(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.StudyStatistics.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve statistics for a single Study 🔭.

 Supports the `study_statistics` scope.

Sends `GET /api/study/{study_id}/statistics`. [API reference](https://data.castoredc.com/api#/study-statistics/get_study__study_id__statistics)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

Every option is passed to `Req`.

# `get_study_statistics!`

```elixir
@spec get_study_statistics!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Model.StudyStatistics.t()
```

The same as `get_study_statistics/3`, returning the result or raising `CastorEDC.Error`.

# `list_studies`

```elixir
@spec list_studies(CastorEDC.client(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Study.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a list of studies the current authenticated user has access to.

Sends `GET /api/study`. [API reference](https://data.castoredc.com/api#/study/get_study)

Every option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Study.t/0` records.

# `list_studies!`

```elixir
@spec list_studies!(CastorEDC.client(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Study.t())
```

The same as `list_studies/2`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
