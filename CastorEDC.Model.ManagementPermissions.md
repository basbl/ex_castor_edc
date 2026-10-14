# `CastorEDC.Model.ManagementPermissions`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/management_permissions.ex#L4)

The `ManagementPermissions` object of the API.

## Fields

  * `:manage_encryption` (boolean)
  * `:manage_form` (boolean)
  * `:manage_participants` (boolean)
  * `:manage_settings` (boolean)
  * `:manage_users` (boolean)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ManagementPermissions{
  extra: %{optional(String.t()) =&gt; term()},
  manage_encryption: boolean() | nil,
  manage_form: boolean() | nil,
  manage_participants: boolean() | nil,
  manage_settings: boolean() | nil,
  manage_users: boolean() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
