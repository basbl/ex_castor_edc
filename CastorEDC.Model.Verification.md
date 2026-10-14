# `CastorEDC.Model.Verification`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/verification.ex#L4)

The `Verification` object of the API.

## Fields

  * `:changed_field` (string)
  * `:dropped_by` (string)
  * `:dropped_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:entity_id` (string)
  * `:entity_type` (string)
  * `:id` (integer)
  * `:parent_id` (string)
  * `:participant_id` (string)
  * `:status` (string) - The status of the verification, can be 'active' or 'dropped'
  * `:verification_type` (`t:CastorEDC.Model.VerificationType.t/0`)
  * `:verified_by` (string)
  * `:verified_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Verification{
  changed_field: String.t() | nil,
  dropped_by: String.t() | nil,
  dropped_on: DateTime.t() | nil,
  entity_id: String.t() | nil,
  entity_type: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: integer() | nil,
  parent_id: String.t() | nil,
  participant_id: String.t() | nil,
  status: String.t() | nil,
  verification_type: CastorEDC.Model.VerificationType.t() | nil,
  verified_by: String.t() | nil,
  verified_on: DateTime.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
