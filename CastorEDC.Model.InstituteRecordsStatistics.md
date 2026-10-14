# `CastorEDC.Model.InstituteRecordsStatistics`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/institute_records_statistics.ex#L4)

The `InstituteRecordsStatistics` object of the API.

## Fields

  * `:institute_id` (string)
  * `:institute_name` (string)
  * `:participant_count` (integer)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.InstituteRecordsStatistics{
  extra: %{optional(String.t()) =&gt; term()},
  institute_id: String.t() | nil,
  institute_name: String.t() | nil,
  participant_count: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
