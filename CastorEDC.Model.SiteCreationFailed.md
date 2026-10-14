# `CastorEDC.Model.SiteCreationFailed`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/site_creation_failed.ex#L4)

The `SiteCreationFailed` object of the API.

## Fields

  * `:code` (string)
  * `:id` (string)
  * `:message` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SiteCreationFailed{
  code: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  message: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
