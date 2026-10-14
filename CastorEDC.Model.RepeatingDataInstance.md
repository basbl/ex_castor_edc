# `CastorEDC.Model.RepeatingDataInstance`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/repeating_data_instance.ex#L4)

The repeating data instance is an instantiation of repeating data,
a real copy of repeating data to which the data points get saved.

## Fields

  * `:archived` (boolean) - Is the repeating data instance archived?
  * `:created_by` (string) - ID of the user who created the repeating data instance.
  * `:created_on` (`NaiveDateTime`) - the date the repeating data instance was created.
  * `:id` (string) - Unique id of the repeating data instance.
  * `:name` (string) - Name of the repeating data instance.
  * `:parent_id` (string) - The parent id.
  * `:parent_type` (string) - The parent type.
  * `:participant_id` (string) - The participant it belongs to.
  * `:repeating_data` (`t:CastorEDC.Model.RepeatingData.t/0`)
  * `:repeating_data_name` (string) - Name of the repeating data.
  * `:status` (string) - The status.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RepeatingDataInstance{
  archived: boolean() | nil,
  created_by: String.t() | nil,
  created_on: NaiveDateTime.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  name: String.t() | nil,
  parent_id: String.t() | nil,
  parent_type: String.t() | nil,
  participant_id: String.t() | nil,
  repeating_data: CastorEDC.Model.RepeatingData.t() | nil,
  repeating_data_name: String.t() | nil,
  status: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
