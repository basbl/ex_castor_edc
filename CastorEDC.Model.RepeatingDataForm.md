# `CastorEDC.Model.RepeatingDataForm`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/repeating_data_form.ex#L4)

The `RepeatingDataForm` object of the API.

## Fields

  * `:id` (string) - Unique identifier of the RepeatingDataForm (same as repeating_data_form_id)
  * `:repeating_data` (`t:CastorEDC.Model.RepeatingData.t/0`)
  * `:repeating_data_form_description` (string) - RepeatingDataForm description
  * `:repeating_data_form_id` (string) - Unique identifier of the RepeatingDataForm (same as id)
  * `:repeating_data_form_name` (string) - RepeatingDataForm name
  * `:repeating_data_form_number` (integer) - The RepeatingDataForms's order within the study
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RepeatingDataForm{
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  repeating_data: CastorEDC.Model.RepeatingData.t() | nil,
  repeating_data_form_description: String.t() | nil,
  repeating_data_form_id: String.t() | nil,
  repeating_data_form_name: String.t() | nil,
  repeating_data_form_number: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
