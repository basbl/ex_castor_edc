# `CastorEDC.Model.FieldDomain`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/field_domain.ex#L4)

The `FieldDomain` object of the API.

## Fields

  * `:abbreviation` (string) - Abbreviated domain name
  * `:domain_variable_name` (string) - Domain variable name
  * `:name` (string) - Full domain name
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.FieldDomain{
  abbreviation: String.t() | nil,
  domain_variable_name: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  name: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
