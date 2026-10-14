# `CastorEDC.Model.FieldOption`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/field_option.ex#L4)

The `FieldOption` object of the API.

## Fields

  * `:domain_variable_name_override` (string) - The variable name to use for this option in domain mappings, when it differs.
  * `:group_order` (integer) - The position of the option within the group
  * `:id` (string) - Unique identifier of the Option
  * `:name` (string) - The Option name
  * `:value` (string) - The Option value
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.FieldOption{
  domain_variable_name_override: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  group_order: integer() | nil,
  id: String.t() | nil,
  name: String.t() | nil,
  value: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
