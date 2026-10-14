# `CastorEDC.Model.ExportEntry`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/model/export_entry.ex#L4)

The `ExportEntry` object of the API.

## Fields

  * `:completed_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:created_by` (string) - The ID of the user who requested the export.
  * `:created_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:expires_on` (`DateTime`) - A DateTime in the server's time zone (see CastorEDC.time_zone/1); compare it with DateTime.compare/2.
  * `:file_name` (string)
  * `:file_size` (integer)
  * `:format` (string, one of `csv`, `excel`, `spss`, `sas_xpt`, `sas_7bdat`, `odm`, `pdf`, `xml`, `zip`) - The export format, despite the name.
  * `:id` (string)
  * `:status` (string, one of `queued`, `in_progress`, `ready`, `failed`)
  * `:type` (string, one of `audit_trail`, `domain_mapping`, `empty_crf`, `form_structure`, `participant_casebook`, `participant_data`, `queries`, `sites`, `survey_compliance`, `uploaded_files`, `validations`) - The export type, despite the name.
  * `:extra` - every key the API sent that this struct doesn't name, under the API's own name.

# `t`

```elixir
@type t() :: %CastorEDC.Model.ExportEntry{
  completed_on: DateTime.t() | nil,
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  expires_on: DateTime.t() | nil,
  extra: %{optional(String.t()) =&gt; term()},
  file_name: String.t() | nil,
  file_size: integer() | nil,
  format: String.t() | nil,
  id: String.t() | nil,
  status: String.t() | nil,
  type: String.t() | nil
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
