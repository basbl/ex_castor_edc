# `CastorEDC.Model.Metadata`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/metadata.ex#L4)

The `Metadata` object of the API.

## Fields

  * `:description` (string) - The description
  * `:id` (string) - Unique identifier of the Metadata
  * `:metadata_type` (`t:CastorEDC.Model.MetadataType.t/0`)
  * `:parent_id` (string) - Metadata id of this metadata's parent (circular reference)
  * `:value` (string) - The value
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.Metadata{
  description: String.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  id: String.t() | nil,
  metadata_type: CastorEDC.Model.MetadataType.t() | nil,
  parent_id: String.t() | nil,
  value: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
