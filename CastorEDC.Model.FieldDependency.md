# `CastorEDC.Model.FieldDependency`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/field_dependency.ex#L4)

The `FieldDependency` object of the API.

## Fields

  * `:child_id` (string) - The ID of the child field (the field that depends on the parent)
  * `:id` (integer) - Unique identifier of the FieldDependency
  * `:operator` (string) - The dependency operator (e.g., ==, !=, >, <)
  * `:parent_id` (string) - The ID of the parent field (the field being checked)
  * `:value` (string) - The value that the parent field is compared against
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.FieldDependency{
  child_id: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: integer() | nil,
  operator: String.t() | nil,
  parent_id: String.t() | nil,
  value: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
