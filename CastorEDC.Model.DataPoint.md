# `CastorEDC.Model.DataPoint`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/data_point.ex#L4)

A stored value of one field, for a participant, in the context of the study, a survey (package) instance or a repeating data instance.

## Fields

  * `:field` (`t:CastorEDC.Model.Field.t/0`)
  * `:field_id` (string)
  * `:field_variable_name` (string) - Only present on single data points.
  * `:participant` (`t:CastorEDC.Model.Participant.t/0`)
  * `:participant_id` (string)
  * `:repeating_data_instance` (`t:CastorEDC.Model.RepeatingDataInstance.t/0`) - The repeating data instance is an instantiation of repeating data, a real copy of repeating data to which the data points get saved.
  * `:repeating_data_instance_id` (string)
  * `:repeating_data_instance_name` (string)
  * `:survey_instance_id` (string)
  * `:survey_name` (string)
  * `:survey_package_id` (string)
  * `:survey_package_instance_id` (string)
  * `:updated_on` (`NaiveDateTime`) - When the value last changed, in the server's local time, not UTC; see CastorEDC.time_zone/1.
  * `:value` (string) - The stored value, always a string; see CastorEDC.FieldValue for decoding it by field type. A value that was cleared stays in the lists, as an empty string with its own updated_on.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.DataPoint{
  extra: %{optional(String.t()) =&gt; term()},
  field: CastorEDC.Model.Field.t() | nil,
  field_id: String.t() | nil,
  field_variable_name: String.t() | nil,
  participant: CastorEDC.Model.Participant.t() | nil,
  participant_id: String.t() | nil,
  repeating_data_instance: CastorEDC.Model.RepeatingDataInstance.t() | nil,
  repeating_data_instance_id: String.t() | nil,
  repeating_data_instance_name: String.t() | nil,
  survey_instance_id: String.t() | nil,
  survey_name: String.t() | nil,
  survey_package_id: String.t() | nil,
  survey_package_instance_id: String.t() | nil,
  updated_on: NaiveDateTime.t() | nil,
  value: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
