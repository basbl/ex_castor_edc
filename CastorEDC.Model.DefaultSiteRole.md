# `CastorEDC.Model.DefaultSiteRole`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/default_site_role.ex#L4)

The `DefaultSiteRole` object of the API.

## Fields

  * `:role_id` (string)
  * `:role_name` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.DefaultSiteRole{
  extra: %{optional(String.t()) =&gt; term()},
  role_id: String.t() | nil,
  role_name: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
