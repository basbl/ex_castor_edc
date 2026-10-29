# `CastorEDC.Model.ParticipantProgressRepeatingDataCollection`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/participant_progress_repeating_data_collection.ex#L4)

The `ParticipantProgressRepeatingDataCollection` object of the API.

## Fields

  * `:archived` (boolean) - Flags whether this repeating data is archived
  * `:complete` (integer) - Completion status of a repeating data instance (0 - Not started, 1 - In Progress, 2 - Done)
  * `:forms` (list of object) - The progress of each form.
  * `:locked` (boolean) - If this repeating data instance is source data locked
  * `:parent_id` (string) - Unique identifier of the parent
  * `:participant_id` (string)
  * `:progress` (integer) - Percentage of completion
  * `:repeating_data_id` (string) - Unique identifier of the repeating data
  * `:repeating_data_instance_id` (string) - 
  * `:sdv` (boolean) - If this repeating data instance is source data verified
  * `:signed` (boolean) - If this repeating data instance is source data signed
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ParticipantProgressRepeatingDataCollection{
  archived: boolean() | nil,
  complete: integer() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  forms: [map()] | nil,
  locked: boolean() | nil,
  parent_id: String.t() | nil,
  participant_id: String.t() | nil,
  progress: integer() | nil,
  repeating_data_id: String.t() | nil,
  repeating_data_instance_id: String.t() | nil,
  sdv: boolean() | nil,
  signed: boolean() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
