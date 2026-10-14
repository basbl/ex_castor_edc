# `CastorEDC.Model.RepeatingDataInstanceCreationFailed`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/repeating_data_instance_creation_failed.ex#L4)

The `RepeatingDataInstanceCreationFailed` object of the API.

## Fields

  * `:code` (string)
  * `:data` (object)
  * `:id` (string)
  * `:message` (string)
  * `:participant_id` (string)
  * `:repeating_data_id` (string)
  * `:repeating_data_name_custom` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RepeatingDataInstanceCreationFailed{
  code: String.t() | nil,
  data: map() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  message: String.t() | nil,
  participant_id: String.t() | nil,
  repeating_data_id: String.t() | nil,
  repeating_data_name_custom: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
