# `CastorEDC.Model.RepeatingData`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/repeating_data.ex#L4)

The `RepeatingData` object of the API.

## Fields

  * `:description` (string) - Description of the Repeating Data
  * `:id` (string) - Unique identifier of the Repeating Data (same as repeating_data_id)
  * `:name` (string) - Name of the Repeating Data
  * `:repeating_data_id` (string) - Unique identifier of the Repeating Data(same as id)
  * `:type` (string) - The repeating data type (event, medication, repeated_measure or other)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RepeatingData{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  name: String.t() | nil,
  repeating_data_id: String.t() | nil,
  type: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
