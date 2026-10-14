# `CastorEDC.Model.SurveyPackageInstance`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/survey_package_instance.ex#L4)

The SurveyPackageInstance is an instantiation of a SurveyPackage,
a real copy a SurveyPackage that gets sent to survey participants.

## Fields

  * `:all_fields_filled_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:archived` (boolean) - Archived SurveyPackageInstances are invisible to the enduser. Invitations will not be sent and data will not be exported .
  * `:auto_lock_on_finish` (boolean) - Whether this SurveyPackageInstance shall be locked upon completion
  * `:available_from` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:created_by` (string) - The user ID of the user who created this instance.
  * `:created_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:expire_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:finished_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:first_opened_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:id` (string) - Unique id of the SurveyPackageInstance. Synonymous to survey_package_instance_id
  * `:invitation_content` (string) - The email invitation message for this SurveyPackageInstance.
  * `:invitation_subject` (string) - The  email subject used in the invitation message for this SurveyPackageInstance.
  * `:locked` (boolean) - Whether this SurveyPackageInstance is locked or not. Locked ones cannot be updated
  * `:parent_id` (string) - The UUID of the parent instance.
  * `:parent_type` (string) - 0: No parent. 1: The survey belongs to a visit. 2: The survey belongs to a repeating data instance.
  * `:participant` (`t:CastorEDC.Model.Participant.t/0`)
  * `:participant_id` (string) - The identifier of the Participant this SurveyPackageInstance belongs to.
  * `:progress` (integer) - The progress of the SurveyPackageInstance, from 0 to 100
  * `:received_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:sent_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:site` (`t:CastorEDC.Model.Site.t/0`)
  * `:site_id` (string) - The identifier of the Site this SurveyPackageInstance's Participant belongs to
  * `:site_name` (string) - The name of the Site this SurveyPackageInstance's Participant belongs to .
  * `:started_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:status` (string) - The status of the survey package instance
  * `:survey_instances` (list of object)
  * `:survey_package` (`t:CastorEDC.Model.SurveyPackage.t/0`)
  * `:survey_package_id` (string) - The identifier of the SurveyPackage of which this SurveyPackageInstance is an instantiation from
  * `:survey_package_instance_id` (string) - Unique identifier for the SurveyPackageInstance. Synonymous to id.
  * `:survey_package_name` (string) - The name of the SurveyPackage of which this SurveyPackageInstance is an instantiation from .
  * `:survey_reminders` (`t:CastorEDC.Model.SurveyPackageReminder.t/0`)
  * `:survey_url_string` (string) - The unique identifier used in the URL to open this specific SurveyPackageInstance. URL should point to https://hostname/survey/survey_url_string.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SurveyPackageInstance{
  all_fields_filled_on: DateTime.t() | nil,
  archived: boolean() | nil,
  auto_lock_on_finish: boolean() | nil,
  available_from: DateTime.t() | nil,
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  expire_on: DateTime.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  finished_on: DateTime.t() | nil,
  first_opened_on: DateTime.t() | nil,
  id: String.t() | nil,
  invitation_content: String.t() | nil,
  invitation_subject: String.t() | nil,
  locked: boolean() | nil,
  parent_id: String.t() | nil,
  parent_type: String.t() | nil,
  participant: CastorEDC.Model.Participant.t() | nil,
  participant_id: String.t() | nil,
  progress: integer() | nil,
  received_on: DateTime.t() | nil,
  sent_on: DateTime.t() | nil,
  site: CastorEDC.Model.Site.t() | nil,
  site_id: String.t() | nil,
  site_name: String.t() | nil,
  started_on: DateTime.t() | nil,
  status: String.t() | nil,
  survey_instances: [map()] | nil,
  survey_package: CastorEDC.Model.SurveyPackage.t() | nil,
  survey_package_id: String.t() | nil,
  survey_package_instance_id: String.t() | nil,
  survey_package_name: String.t() | nil,
  survey_reminders: CastorEDC.Model.SurveyPackageReminder.t() | nil,
  survey_url_string: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
