# `CastorEDC.Model.StudyUser`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/study_user.ex#L4)

The `StudyUser` object of the API.

## Fields

  * `:default_role_assignment` (`t:CastorEDC.Model.DefaultSiteRole.t/0`)
  * `:department` (string)
  * `:email_address` (string)
  * `:entity_id` (string)
  * `:full_name` (string)
  * `:id` (string)
  * `:last_login` (`NaiveDateTime`)
  * `:manage_permissions` (`t:CastorEDC.Model.ManagementPermissions.t/0`)
  * `:name_first` (string)
  * `:name_last` (string)
  * `:name_middle` (string)
  * `:role_assignments` (list of `t:CastorEDC.Model.RoleAssignments.t/0`)
  * `:user_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.StudyUser{
  default_role_assignment: CastorEDC.Model.DefaultSiteRole.t() | nil,
  department: String.t() | nil,
  email_address: String.t() | nil,
  entity_id: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  full_name: String.t() | nil,
  id: String.t() | nil,
  last_login: NaiveDateTime.t() | nil,
  manage_permissions: CastorEDC.Model.ManagementPermissions.t() | nil,
  name_first: String.t() | nil,
  name_last: String.t() | nil,
  name_middle: String.t() | nil,
  role_assignments: [CastorEDC.Model.RoleAssignments.t()] | nil,
  user_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
