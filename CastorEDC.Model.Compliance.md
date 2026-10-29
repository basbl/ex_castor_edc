# `CastorEDC.Model.Compliance`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/compliance.ex#L4)

Compliance overview of participant surveys

## Fields

  * `:completed_surveys` (integer) - Total number of completed surveys used for the compliance calculation
  * `:compliance` (integer) - The compliance percentage of the participant, represented as 0 - 100 integer value
  * `:participant_id` (string)
  * `:participant_status` (string)
  * `:site_id` (string)
  * `:site_name` (string)
  * `:total_surveys` (integer) - Total number of surveys used for the compliance calculation
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Compliance{
  completed_surveys: integer() | nil,
  compliance: integer() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  participant_id: String.t() | nil,
  participant_status: String.t() | nil,
  site_id: String.t() | nil,
  site_name: String.t() | nil,
  total_surveys: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
