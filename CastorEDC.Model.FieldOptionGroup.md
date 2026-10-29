# `CastorEDC.Model.FieldOptionGroup`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/field_option_group.ex#L4)

The `FieldOptionGroup` object of the API.

## Fields

  * `:description` (string) - The FieldOptionGroup description
  * `:id` (string) - Unique identifier of the FieldOptionGroup
  * `:layout` (any) - Horizontal or vertical option positioning
  * `:name` (string) - The FieldOptionGroup name
  * `:options` (list of `t:CastorEDC.Model.FieldOption.t/0`) - The list of FieldOptions that are included in this FieldOptionGroup
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.FieldOptionGroup{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  layout: term() | nil,
  name: String.t() | nil,
  options: [CastorEDC.Model.FieldOption.t()] | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
