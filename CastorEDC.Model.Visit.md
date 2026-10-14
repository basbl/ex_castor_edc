# `CastorEDC.Model.Visit`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/visit.ex#L4)

The `Visit` object of the API.

## Fields

  * `:id` (string) - Unique identifier of the Visit (same as visit_id)
  * `:visit_description` (string) - the Visit description
  * `:visit_duration` (number) - the Visit's duration
  * `:visit_id` (string) - Unique identifier of the Visit (same as id)
  * `:visit_name` (string) - the Visit label
  * `:visit_number` (integer) - the Visit's number (unique)
  * `:visit_order` (integer) - the Visit's order
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Visit{
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  visit_description: String.t() | nil,
  visit_duration: number() | nil,
  visit_id: String.t() | nil,
  visit_name: String.t() | nil,
  visit_number: integer() | nil,
  visit_order: integer() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
