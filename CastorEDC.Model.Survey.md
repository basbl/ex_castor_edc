# `CastorEDC.Model.Survey`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/survey.ex#L4)

The `Survey` object of the API.

## Fields

  * `:description` (string)
  * `:footer_text` (string)
  * `:id` (string)
  * `:intro_text` (string)
  * `:name` (string)
  * `:outro_text` (string)
  * `:survey_forms` (list of object) - Only included with `?include=forms`, otherwise returns an empty array.
  * `:survey_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Survey{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  footer_text: String.t() | nil,
  id: String.t() | nil,
  intro_text: String.t() | nil,
  name: String.t() | nil,
  outro_text: String.t() | nil,
  survey_forms: [map()] | nil,
  survey_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
