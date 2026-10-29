# `CastorEDC.Model.InvitationSuccess`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/invitation_success.ex#L4)

The `InvitationSuccess` object of the API.

## Fields

  * `:id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.InvitationSuccess{
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
