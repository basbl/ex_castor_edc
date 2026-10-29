# `CastorEDC.Model.RoleAssignments`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/role_assignments.ex#L4)

The `RoleAssignments` object of the API.

## Fields

  * `:permissions` (object)
  * `:role_id` (string)
  * `:role_name` (string)
  * `:site_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RoleAssignments{
  extra: %{optional(String.t()) =&gt; term()},
  permissions: map() | nil,
  role_id: String.t() | nil,
  role_name: String.t() | nil,
  site_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
