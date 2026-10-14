# `CastorEDC.Model.Site`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/site.ex#L4)

The `Site` object of the API.

## Fields

  * `:abbreviation` (string)
  * `:code` (string)
  * `:country_id` (integer)
  * `:date_display_format` (string) - The same format for display, such as `YYYY-MM-DD`.
  * `:date_format` (string) - The site's date format, such as `Y-m-d`.
  * `:deleted` (boolean)
  * `:id` (string)
  * `:name` (string)
  * `:order` (integer)
  * `:site_id` (string) - The same as `id`.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Site{
  abbreviation: String.t() | nil,
  code: String.t() | nil,
  country_id: integer() | nil,
  date_display_format: String.t() | nil,
  date_format: String.t() | nil,
  deleted: boolean() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  name: String.t() | nil,
  order: integer() | nil,
  site_id: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
