# `CastorEDC.Model.RandomizationDetails`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/randomization_details.ex#L4)

The `RandomizationDetails` object of the API.

## Fields

  * `:randomization_group` (integer)
  * `:randomization_group_name` (string)
  * `:randomized_id` (string)
  * `:randomized_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.RandomizationDetails{
  extra: %{optional(String.t()) =&gt; term()},
  randomization_group: integer() | nil,
  randomization_group_name: String.t() | nil,
  randomized_id: String.t() | nil,
  randomized_on: DateTime.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
