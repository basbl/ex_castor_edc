# `CastorEDC.Model.SiteCollection`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/site_collection.ex#L4)

## Fields

  * `:failed` (list of `t:CastorEDC.Model.SiteCreationFailed.t/0`)
  * `:saved` (list of `t:CastorEDC.Model.Site.t/0`)
  * `:total_failed` (integer)
  * `:total_processed` (integer)
  * `:total_success` (integer)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SiteCollection{
  extra: %{optional(String.t()) =&gt; term()},
  failed: [CastorEDC.Model.SiteCreationFailed.t()] | nil,
  saved: [CastorEDC.Model.Site.t()] | nil,
  total_failed: integer() | nil,
  total_processed: integer() | nil,
  total_success: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
