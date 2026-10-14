# `CastorEDC.Model.StudyRecordsStatistics`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/study_records_statistics.ex#L4)

The `StudyRecordsStatistics` object of the API.

## Fields

  * `:institutes` (`t:CastorEDC.Model.InstituteRecordsStatistics.t/0`)
  * `:total_count` (integer)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.StudyRecordsStatistics{
  extra: %{optional(String.t()) =&gt; term()},
  institutes: CastorEDC.Model.InstituteRecordsStatistics.t() | nil,
  total_count: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
