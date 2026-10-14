# `CastorEDC.Model.SurveyForm`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/survey_form.ex#L4)

The `SurveyForm` object of the API.

## Fields

  * `:field_alignment` (string, one of `left-aligned`, `center-aligned`) - Sets how fields & responses are aligned in survey data entry.
  * `:footer_text` (string)
  * `:form_numbering` (string, one of `visible`, `hidden`) - Setting whether field numbers are rendered on this form.
  * `:id` (string) - Unique identifier of the SurveyForm (same as survey_form_id)
  * `:label_bold_if_required` (boolean) - Render field labels in bold if the field is required. Defaults to `true`.
  * `:survey` (`t:CastorEDC.Model.Survey.t/0`)
  * `:survey_form_description` (string) - SurveyForm description
  * `:survey_form_id` (string) - Unique identifier of the SurveyForm (same as id)
  * `:survey_form_name` (string) - SurveyForm name
  * `:survey_form_number` (integer) - The SurveyForms's order within the study
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.SurveyForm{
  extra: %{optional(String.t()) =&gt; term()},
  field_alignment: String.t() | nil,
  footer_text: String.t() | nil,
  form_numbering: String.t() | nil,
  id: String.t() | nil,
  label_bold_if_required: boolean() | nil,
  survey: CastorEDC.Model.Survey.t() | nil,
  survey_form_description: String.t() | nil,
  survey_form_id: String.t() | nil,
  survey_form_name: String.t() | nil,
  survey_form_number: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
