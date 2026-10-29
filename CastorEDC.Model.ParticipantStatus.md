# `CastorEDC.Model.ParticipantStatus`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/participant_status.ex#L4)

The `ParticipantStatus` object of the API.

## Fields

  * `:id` (string)
  * `:name` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ParticipantStatus{
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  name: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
