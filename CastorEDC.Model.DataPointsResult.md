# `CastorEDC.Model.DataPointsResult`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/data_points_result.ex#L4)

The `DataPointsResult` object of the API.

## Fields

  * `:failed` (list of `t:CastorEDC.Model.DataPointFailure.t/0`)
  * `:saved` (list of `t:CastorEDC.Model.DataPoint.t/0`)
  * `:survey_package_instance_id` (string) - Only when the write created a survey package instance.
  * `:total_failed` (integer)
  * `:total_processed` (integer)
  * `:total_success` (integer)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.DataPointsResult{
  extra: %{optional(String.t()) =&gt; term()},
  failed: [CastorEDC.Model.DataPointFailure.t()] | nil,
  saved: [CastorEDC.Model.DataPoint.t()] | nil,
  survey_package_instance_id: String.t() | nil,
  total_failed: integer() | nil,
  total_processed: integer() | nil,
  total_success: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
