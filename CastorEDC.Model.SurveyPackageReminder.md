# `CastorEDC.Model.SurveyPackageReminder`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/survey_package_reminder.ex#L4)

The `SurveyPackageReminder` object of the API.

## Fields

  * `:id` (string) - Unique id of the SurveyPackageReminder
  * `:message` (string) - The email content used in the reminder message for this SurveyPackage
  * `:send_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:subject` (string) - The email subject used in the reminder message for this SurveyPackage
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SurveyPackageReminder{
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  message: String.t() | nil,
  send_on: DateTime.t() | nil,
  subject: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
