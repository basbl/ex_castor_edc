# `CastorEDC.Model.MetadataType`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model/metadata_type.ex#L4)

The `MetadataType` object of the API.

## Fields

  * `:description` (string) - The description of this MetadataType
  * `:id` (string) - Unique identifier of the MetadataType
  * `:name` (string) - The name of this MetadataType
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.MetadataType{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  name: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
