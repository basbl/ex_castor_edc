# `CastorEDC.Countries`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/countries.ex#L4)

The countries Castor EDC knows, for site and participant addresses.

## Operations

  * `get_country/3` - Retrieve a single Country
  * `list_countries/2` - Retrieves the list of all countries

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_country`

```elixir
@spec get_country(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Country.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Country.

Sends `GET /api/country/{country_id}`. [API reference](https://data.castoredc.com/api#/country/get_country__country_id_)

## Arguments

  * `country_id` - ID of the country to fetch

Every option is passed to `Req`.

# `get_country!`

```elixir
@spec get_country!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Model.Country.t()
```

The same as `get_country/3`, returning the result or raising `CastorEDC.Error`.

# `list_countries`

```elixir
@spec list_countries(CastorEDC.client(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Country.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves the list of all countries.

Gets `Country` objects.
Is not paged.

Sends `GET /api/country`. [API reference](https://data.castoredc.com/api#/country/get_country)

Every option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Country.t/0` records.

# `list_countries!`

```elixir
@spec list_countries!(CastorEDC.client(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Country.t())
```

The same as `list_countries/2`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
