# `CastorEDC.Model.Study`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/study.ex#L4)

The `Study` object of the API.

## Fields

  * `:created_by` (string)
  * `:created_on` (`NaiveDateTime`)
  * `:crf_id` (string) - The ID of the study's case report form.
  * `:domain` (string)
  * `:duration` (number)
  * `:encryption` (boolean)
  * `:expected_centers` (integer)
  * `:expected_participants` (integer)
  * `:first_live_on` (`NaiveDateTime`)
  * `:gcp_enabled` (boolean)
  * `:last_datapoint_collected_on` (`NaiveDateTime`)
  * `:live` (boolean)
  * `:main_contact` (string)
  * `:name` (string)
  * `:on_site_epro_mode_enabled` (boolean)
  * `:premium_support_enabled` (boolean)
  * `:randomization_enabled` (boolean)
  * `:slug` (string)
  * `:study_id` (string)
  * `:surveys_enabled` (boolean)
  * `:trial_registry_id` (string)
  * `:version` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Study{
  created_by: String.t() | nil,
  created_on: NaiveDateTime.t() | nil,
  crf_id: String.t() | nil,
  domain: String.t() | nil,
  duration: number() | nil,
  encryption: boolean() | nil,
  expected_centers: integer() | nil,
  expected_participants: integer() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  first_live_on: NaiveDateTime.t() | nil,
  gcp_enabled: boolean() | nil,
  last_datapoint_collected_on: NaiveDateTime.t() | nil,
  live: boolean() | nil,
  main_contact: String.t() | nil,
  name: String.t() | nil,
  on_site_epro_mode_enabled: boolean() | nil,
  premium_support_enabled: boolean() | nil,
  randomization_enabled: boolean() | nil,
  slug: String.t() | nil,
  study_id: String.t() | nil,
  surveys_enabled: boolean() | nil,
  trial_registry_id: String.t() | nil,
  version: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
