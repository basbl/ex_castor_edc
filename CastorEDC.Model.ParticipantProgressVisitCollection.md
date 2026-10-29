# `CastorEDC.Model.ParticipantProgressVisitCollection`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/participant_progress_visit_collection.ex#L4)

The `ParticipantProgressVisitCollection` object of the API.

## Fields

  * `:complete` (integer) - Completion status of a visit (0 - Not started, 1 - In Progress, 2 - Done)
  * `:forms` (list of object) - The progress of each form.
  * `:locked` (boolean) - If this visit instance is source data locked
  * `:participant_id` (string)
  * `:progress` (integer) - Percentage of completion
  * `:sdv` (boolean) - If this visit instance is source data verified
  * `:signed` (boolean) - If this visit instance is source data signed
  * `:visit_id` (string) - 
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ParticipantProgressVisitCollection{
  complete: integer() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  forms: [map()] | nil,
  locked: boolean() | nil,
  participant_id: String.t() | nil,
  progress: integer() | nil,
  sdv: boolean() | nil,
  signed: boolean() | nil,
  visit_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
