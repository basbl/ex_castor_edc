# `CastorEDC.Model.ParticipantProgress`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/participant_progress.ex#L4)

The `ParticipantProgress` object of the API.

## Fields

  * `:forms` (list of any) - List of forms and their statuses
  * `:participant_id` (string) - Participant identifier
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ParticipantProgress{
  extra: %{optional(String.t()) =&gt; term()},
  forms: [term()] | nil,
  participant_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
