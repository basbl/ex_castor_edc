# `CastorEDC.Model.VerificationType`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/verification_type.ex#L4)

The `VerificationType` object of the API.

## Fields

  * `:id` (integer)
  * `:is_sdv` (boolean)
  * `:name` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.VerificationType{
  extra: %{optional(String.t()) =&gt; term()},
  id: integer() | nil,
  is_sdv: boolean() | nil,
  name: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
