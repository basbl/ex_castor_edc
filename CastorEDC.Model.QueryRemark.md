# `CastorEDC.Model.QueryRemark`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/query_remark.ex#L4)

The `QueryRemark` object of the API.

## Fields

  * `:created_by` (string)
  * `:created_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:description` (string)
  * `:id` (string)
  * `:title` (string)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.QueryRemark{
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  title: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
