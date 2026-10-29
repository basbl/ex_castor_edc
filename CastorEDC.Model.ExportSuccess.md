# `CastorEDC.Model.ExportSuccess`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/export_success.ex#L4)

The `ExportSuccess` object of the API.

## Fields

  * `:description` (string)
  * `:queued_exports` (list of string)
  * `:success` (boolean)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ExportSuccess{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  queued_exports: [String.t()] | nil,
  success: boolean() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
