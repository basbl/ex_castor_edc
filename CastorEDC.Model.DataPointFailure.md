# `CastorEDC.Model.DataPointFailure`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/data_point_failure.ex#L4)

The `DataPointFailure` object of the API.

## Fields

  * `:code` (string)
  * `:data` (any)
  * `:field_id` (string)
  * `:id` (string) - A reference Castor support can trace.
  * `:message` (string)
  * `:participant_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.DataPointFailure{
  code: String.t() | nil,
  data: term() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  field_id: String.t() | nil,
  id: String.t() | nil,
  message: String.t() | nil,
  participant_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
