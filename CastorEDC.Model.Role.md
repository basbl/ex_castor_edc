# `CastorEDC.Model.Role`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/role.ex#L4)

The `Role` object of the API.

## Fields

  * `:description` (string) - Role description
  * `:name` (string) - Role name
  * `:permissions` (object)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Role{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  name: String.t() | nil,
  permissions: map() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
