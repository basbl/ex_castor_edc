# `CastorEDC.Model.Form`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/form.ex#L4)

The `Form` object of the API.

## Fields

  * `:form_description` (string) - the Form description
  * `:form_id` (string) - Unique identifier of the Form (same as id)
  * `:form_name` (string) - the name of the Form
  * `:form_order` (integer) - The Forms's order within the study
  * `:id` (string) - Unique identifier of the Form (same as form_id)
  * `:visit` (`t:CastorEDC.Model.Visit.t/0`)
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Form{
  extra: %{optional(String.t()) =&gt; term()},
  form_description: String.t() | nil,
  form_id: String.t() | nil,
  form_name: String.t() | nil,
  form_order: integer() | nil,
  id: String.t() | nil,
  visit: CastorEDC.Model.Visit.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
