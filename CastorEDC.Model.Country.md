# `CastorEDC.Model.Country`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/country.ex#L4)

The `Country` object of the API.

## Fields

  * `:country_cca2` (string) - Two-letter country abbreviation
  * `:country_cca3` (string) - Three-letter country abbreviation
  * `:country_id` (integer) - Unique identifier of the Country (same as id)
  * `:country_name` (string) - The Country name
  * `:country_tld` (string) - Top level domain name for country
  * `:id` (integer) - Unique identifier of the Country (same as country_id)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Country{
  country_cca2: String.t() | nil,
  country_cca3: String.t() | nil,
  country_id: integer() | nil,
  country_name: String.t() | nil,
  country_tld: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
