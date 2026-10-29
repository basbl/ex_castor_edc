# `CastorEDC.Model.SurveyPackage`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/survey_package.ex#L4)

The `SurveyPackage` object of the API.

## Fields

  * `:allow_form_navigation` (boolean) - Whether survey participants are allowed to navigate between steps
  * `:allow_open_survey_link` (boolean) - Whether an open survey link can be generated for this SurveyPackage
  * `:as_needed` (boolean) - Whether a mobile SurveyPackage can be completed as needed
  * `:auto_5s_redirect` (boolean) - Whether to enable automatic 5 seconds redirect to the finish_url after completion of data entry
  * `:auto_lock_on_finish` (boolean) - Lock instantiations of this SurveyPackage upon completion
  * `:default_invitation` (string) - The default invitation message used for invitation messages in Markdown format. Must contain a {url} tag.
  * `:default_invitation_subject` (string) - The default email subject used in the invitation messages.
  * `:description` (string) - Description of the SurveyPackage
  * `:expire_after_hours` (integer) - Expire after x hours, for mobile enabled SurveyPackages
  * `:field_pagination` (string, one of `none`, `forms`) - Whether mobile SurveyPackage fields should be paginated and how
  * `:finish_url` (string) - The URL where a participant is forwarded to upon completion of data entry
  * `:id` (string) - Unique identifier for the SurveyPackage. Synonymous to survey_package_id.
  * `:intro_text` (string) - The text shown on the introduction page of the data entry of this SurveyPackage
  * `:is_mobile` (boolean) - Whether to send the SurveyPackage via mobile app
  * `:is_repeatable` (boolean) - Whether a mobile SurveyPackage is repeatable
  * `:is_resumable` (boolean) - Whether a mobile SurveyPackage is resumable
  * `:is_training` (boolean) - Whether a mobile SurveyPackage is used for training
  * `:name` (string) - Name of the SurveyPackage
  * `:outro_text` (string) - The text shown on the finishing page of the data entry of this SurveyPackage
  * `:pre_redirect_text` (string) - The text shown on the finishing page of the data entry of this SurveyPackage before the participant is redirected to the finish_url
  * `:sender_email` (string) - Reply-to / sender address on the email invitation
  * `:sender_name` (string) - Name shown as sender on the email invitation
  * `:show_form_navigator` (boolean) - Whether the step navigator is shown in the survey data entry view
  * `:survey_package_id` (string) - Unique identifier for the SurveyPackage. Synonymous to id.
  * `:surveys` (list of `t:CastorEDC.Model.Survey.t/0`) - The surveys in this package.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SurveyPackage{
  allow_form_navigation: boolean() | nil,
  allow_open_survey_link: boolean() | nil,
  as_needed: boolean() | nil,
  auto_5s_redirect: boolean() | nil,
  auto_lock_on_finish: boolean() | nil,
  default_invitation: String.t() | nil,
  default_invitation_subject: String.t() | nil,
  description: String.t() | nil,
  expire_after_hours: integer() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  field_pagination: String.t() | nil,
  finish_url: String.t() | nil,
  id: String.t() | nil,
  intro_text: String.t() | nil,
  is_mobile: boolean() | nil,
  is_repeatable: boolean() | nil,
  is_resumable: boolean() | nil,
  is_training: boolean() | nil,
  name: String.t() | nil,
  outro_text: String.t() | nil,
  pre_redirect_text: String.t() | nil,
  sender_email: String.t() | nil,
  sender_name: String.t() | nil,
  show_form_navigator: boolean() | nil,
  survey_package_id: String.t() | nil,
  surveys: [CastorEDC.Model.Survey.t()] | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
