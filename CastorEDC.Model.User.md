# `CastorEDC.Model.User`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/user.ex#L4)

The `User` object of the API.

## Fields

  * `:default_site_role` (integer)
  * `:department` (string)
  * `:email_address` (string)
  * `:entity_id` (string)
  * `:full_name` (string)
  * `:id` (string)
  * `:institute` (string)
  * `:last_login` (object)
  * `:name_first` (string)
  * `:name_last` (string)
  * `:name_middle` (string)
  * `:user_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.User{
  default_site_role: integer() | nil,
  department: String.t() | nil,
  email_address: String.t() | nil,
  entity_id: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  full_name: String.t() | nil,
  id: String.t() | nil,
  institute: String.t() | nil,
  last_login: map() | nil,
  name_first: String.t() | nil,
  name_last: String.t() | nil,
  name_middle: String.t() | nil,
  user_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
