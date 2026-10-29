# `CastorEDC.Model.FieldValidation`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/field_validation.ex#L4)

The `FieldValidation` object of the API.

## Fields

  * `:field_id` (string) - The field that uses this validation
  * `:id` (string) - Unique identifier of the FieldValidation
  * `:operator` (string) - The comparison the validation makes, such as `>`.
  * `:reference_type` (string, one of `field`, `value`) - The type of validation reference. "field" means comparing against another field, "value" means comparing against a static value
  * `:referenced_field_id` (string) - The ID of the referenced field for field-to-field validations or null for value validations
  * `:text` (string) - The message of the validation
  * `:type` (string) - FieldValidation type
  * `:value` (string) - The static value to compare against or null for field-to-field validations
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.FieldValidation{
  extra: %{optional(String.t()) =&gt; term()},
  field_id: String.t() | nil,
  id: String.t() | nil,
  operator: String.t() | nil,
  reference_type: String.t() | nil,
  referenced_field_id: String.t() | nil,
  text: String.t() | nil,
  type: String.t() | nil,
  value: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
