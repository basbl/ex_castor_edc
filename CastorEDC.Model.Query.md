# `CastorEDC.Model.Query`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/query.ex#L4)

The `Query` object of the API.

## Fields

  * `:created_by` (string)
  * `:created_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:field_id` (string)
  * `:first_query_remark` (string)
  * `:id` (string)
  * `:participant_id` (string)
  * `:query_remarks` (list of `t:CastorEDC.Model.QueryRemark.t/0`)
  * `:status` (string)
  * `:updated_by` (string)
  * `:updated_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Query{
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  field_id: String.t() | nil,
  first_query_remark: String.t() | nil,
  id: String.t() | nil,
  participant_id: String.t() | nil,
  query_remarks: [CastorEDC.Model.QueryRemark.t()] | nil,
  status: String.t() | nil,
  updated_by: String.t() | nil,
  updated_on: DateTime.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
