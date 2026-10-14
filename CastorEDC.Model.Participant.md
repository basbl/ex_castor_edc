# `CastorEDC.Model.Participant`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/participant.ex#L4)

The `Participant` object of the API.

## Fields

  * `:archived` (boolean)
  * `:archived_reason` (string)
  * `:ccr_patient_id` (string)
  * `:created_by` (string)
  * `:created_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:deleted` (boolean)
  * `:id` (string)
  * `:last_opened_form` (string)
  * `:locked` (boolean)
  * `:mobile_my_details_enabled` (boolean) - Feature toggle for My Details within the Castor Connect Mobile App
  * `:mobile_ui_version` (string) - Existing versions are 1.0, 2.0, 3.0, 4.0, 5.0
  * `:participant_id` (string)
  * `:participant_status` (`t:CastorEDC.Model.ParticipantStatus.t/0`)
  * `:progress` (number)
  * `:randomization_group` (integer)
  * `:randomization_group_name` (string)
  * `:randomized_id` (string) - The participant's randomization ID.
  * `:randomized_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:site` (`t:CastorEDC.Model.Site.t/0`)
  * `:status` (string) - Deprecated: use the locked property instead
  * `:updated_by` (string)
  * `:updated_on` (`DateTime`) - When the participant last changed, which includes every value entered for them, to the minute only.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Participant{
  archived: boolean() | nil,
  archived_reason: String.t() | nil,
  ccr_patient_id: String.t() | nil,
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  deleted: boolean() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  last_opened_form: String.t() | nil,
  locked: boolean() | nil,
  mobile_my_details_enabled: boolean() | nil,
  mobile_ui_version: String.t() | nil,
  participant_id: String.t() | nil,
  participant_status: CastorEDC.Model.ParticipantStatus.t() | nil,
  progress: number() | nil,
  randomization_group: integer() | nil,
  randomization_group_name: String.t() | nil,
  randomized_id: String.t() | nil,
  randomized_on: DateTime.t() | nil,
  site: CastorEDC.Model.Site.t() | nil,
  status: String.t() | nil,
  updated_by: String.t() | nil,
  updated_on: DateTime.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
