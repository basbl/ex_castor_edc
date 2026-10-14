# `CastorEDC.Model.Field`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/field.ex#L4)

The `Field` object of the API.

## Fields

  * `:additional_config` (string) - Extra configuration of the field
  * `:dependency_children` (list of `t:CastorEDC.Model.FieldDependencyNested.t/0`) - List of child field dependencies (fields that depend on this field)
  * `:dependency_parents` (list of `t:CastorEDC.Model.FieldDependencyNested.t/0`) - List of parent field dependencies (fields that this field depends on)
  * `:domains` (list of `t:CastorEDC.Model.FieldDomain.t/0`)
  * `:exclude_on_data_export` (boolean) - Whether exports leave the field out.
  * `:field_enforce_decimals` (boolean) - If enabled, it requires decimals digits in data-entry
  * `:field_hidden` (integer) - If enabled, it hides the field in data-entry. Returns 1 for hidden, 0 for visible
  * `:field_id` (string) - Unique identifier of the Field (same as id)
  * `:field_image` (string) - URL to the image for the Image field type
  * `:field_info` (string) - Information about the field. It is shown during data-entry
  * `:field_label` (string) - The Field label
  * `:field_length` (integer) - Length parameter to derive UI input width for this field
  * `:field_max` (number) - The highest value allowed.
  * `:field_max_label` (string) - The label of the highest value
  * `:field_min` (number) - The lowest value allowed.
  * `:field_min_label` (string) - The label of the lowest value
  * `:field_number` (integer) - The Field's position within a step
  * `:field_required` (integer) - If enabled, it makes the field required (cannot be left empty). Returns 1 for required, 0 for not required
  * `:field_slider_step` (string) - Slider step (Deprecated. Use field_slider_step_value instead)
  * `:field_slider_step_value` (number) - Slider step value
  * `:field_summary_template` (string) - The template of a summary field.
  * `:field_type` (string) - The Field type
  * `:field_units` (string) - The field's measurement unit
  * `:field_variable_name` (string) - The Field's variable name
  * `:id` (string) - Unique identifier of the Field (same as field_id)
  * `:metadata_points` (list of `t:CastorEDC.Model.Metadata.t/0`)
  * `:option_group` (`t:CastorEDC.Model.FieldOptionGroup.t/0`) - The field's option group, when listed with include=optiongroup and the field has options.
  * `:parent_id` (string) - The field's parent id
  * `:randomize_option_order` (boolean) - If enabled, the order of options should be randomized (only applies to dropdown, radio, and checkbox fields)
  * `:repeating_data_id` (string)
  * `:validations` (list of `t:CastorEDC.Model.FieldValidation.t/0`)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Field{
  additional_config: String.t() | nil,
  dependency_children: [CastorEDC.Model.FieldDependencyNested.t()] | nil,
  dependency_parents: [CastorEDC.Model.FieldDependencyNested.t()] | nil,
  domains: [CastorEDC.Model.FieldDomain.t()] | nil,
  exclude_on_data_export: boolean() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  field_enforce_decimals: boolean() | nil,
  field_hidden: integer() | nil,
  field_id: String.t() | nil,
  field_image: String.t() | nil,
  field_info: String.t() | nil,
  field_label: String.t() | nil,
  field_length: integer() | nil,
  field_max: number() | nil,
  field_max_label: String.t() | nil,
  field_min: number() | nil,
  field_min_label: String.t() | nil,
  field_number: integer() | nil,
  field_required: integer() | nil,
  field_slider_step: String.t() | nil,
  field_slider_step_value: number() | nil,
  field_summary_template: String.t() | nil,
  field_type: String.t() | nil,
  field_units: String.t() | nil,
  field_variable_name: String.t() | nil,
  id: String.t() | nil,
  metadata_points: [CastorEDC.Model.Metadata.t()] | nil,
  option_group: CastorEDC.Model.FieldOptionGroup.t() | nil,
  parent_id: String.t() | nil,
  randomize_option_order: boolean() | nil,
  repeating_data_id: String.t() | nil,
  validations: [CastorEDC.Model.FieldValidation.t()] | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
