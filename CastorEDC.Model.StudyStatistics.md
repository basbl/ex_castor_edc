# `CastorEDC.Model.StudyStatistics`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/study_statistics.ex#L4)

The `StudyStatistics` object of the API.

## Fields

  * `:participants` (`t:CastorEDC.Model.StudyRecordsStatistics.t/0`)
  * `:study_id` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.StudyStatistics{
  extra: %{optional(String.t()) =&gt; term()},
  participants: CastorEDC.Model.StudyRecordsStatistics.t() | nil,
  study_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
