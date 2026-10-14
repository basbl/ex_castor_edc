# `CastorEDC.Tabular`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/tabular.ex#L1)

A study's data as rows, ready for a dataframe library.

`schema/2` describes the study's fields: their variable names, where they
collect data, and the Elixir type their values decode to.
`data_points/3` streams every value the study collected, decoded, as
rows:

    client
    |> CastorEDC.Tabular.data_points(study_id)
    |> Enum.take(1)
    #=> [%{participant_id: "000001", site_id: "...", source: :study, instance_id: nil,
    #=>    parent_id: nil, field_id: "...", variable_name: "weight", value: 72.5,
    #=>    raw_value: "72.5", updated_on: ~N[2026-10-07 21:49:55]}]

This long format, one row per value, holds the study's, repeating data's
and surveys' values alike and loses nothing, which makes it the default.
With `format: :wide`, there's a row per participant for the study's
values, and a row per instance for repeating data and surveys, with a
column per variable:

    client
    |> CastorEDC.Tabular.data_points(study_id, format: :wide)
    |> Enum.take(1)
    #=> [%{:participant_id => "000001", :site_id => "...", :source => :study, :instance_id => nil,
    #=>    :parent_id => nil, "weight" => 72.5, "sex" => "1", "symptoms_1" => true, ...}]

# `column`

```elixir
@type column() :: %{
  field_id: String.t(),
  variable_name: String.t() | nil,
  label: String.t() | nil,
  field_type: String.t(),
  type: value_type(),
  context: context() | nil,
  parent_id: String.t() | nil,
  parent_name: String.t() | nil,
  form_id: String.t() | nil,
  form_name: String.t() | nil,
  option_group: CastorEDC.Model.FieldOptionGroup.t() | nil,
  position: {non_neg_integer(), integer(), integer(), integer()},
  field: CastorEDC.Model.Field.t()
}
```

A field, as `schema/2` describes it:

  * `:field_id`, `:variable_name`, `:label` and `:field_type` - as the
    field has them
  * `:type` - the Elixir type of its values
  * `:context` - where it collects data, or `nil` when its form is in none
    of the study's visits, repeating data or surveys
  * `:parent_id` and `:parent_name` - the visit, repeating data or survey
    its form belongs to
  * `:form_id` and `:form_name` - its form
  * `:option_group` - the option group of an option field
  * `:position` - where the field sits in the study: sorting columns by
    it puts them in the order the study shows them, visit by visit and
    form by form, then the repeating data and surveys
  * `:field` - the `CastorEDC.Model.Field` itself, which
    `CastorEDC.FieldValue.decode/2` takes

# `context`

```elixir
@type context() :: :study | :repeating_data | :survey
```

Where a field collects data: on a visit's forms, in repeating data, or in
a survey.

# `row`

```elixir
@type row() :: %{
  participant_id: String.t(),
  site_id: String.t() | nil,
  source: context(),
  instance_id: String.t() | nil,
  parent_id: String.t() | nil,
  field_id: String.t(),
  variable_name: String.t() | nil,
  value: CastorEDC.FieldValue.t(),
  raw_value: String.t() | nil,
  updated_on: NaiveDateTime.t() | nil
}
```

A value, as `data_points/3` gives it:

  * `:participant_id` and `:site_id` - whose value it is, and their site
  * `:source` - where it was collected, as in `t:context/0`
  * `:instance_id` - the repeating data instance or survey instance it
    belongs to, or `nil` for the study's values
  * `:parent_id` - the repeating data or survey, or `nil` for the
    study's values
  * `:field_id` and `:variable_name` - its field
  * `:value` - decoded with `CastorEDC.FieldValue.decode/2`
  * `:raw_value` - the string the API sent
  * `:updated_on` - when it last changed, in the server's local time
    (see `CastorEDC.time_zone/1`), not UTC

A value that was cleared is still listed, with `value: nil` and
`raw_value: ""`.

# `value_type`

```elixir
@type value_type() ::
  :number
  | :integer
  | :string
  | :date
  | :time
  | :naive_datetime
  | :partial_date
  | :number_or_string
  | {:list, :string}
  | {:number, :date}
  | :grid
  | :upload
  | :geolocation
```

The Elixir type of a field's decoded values (see
`CastorEDC.FieldValue`), apart from `nil`, `CastorEDC.MissingValue` and
`:encrypted`, which any field can hold:

  * `:number` - an integer or a float
  * `:integer`, `:string`, `:date`, `:time` and `:naive_datetime`
  * `:partial_date` - a `CastorEDC.PartialDate`
  * `:number_or_string` - a calculation's result
  * `{:list, :string}` - a checkbox field's checked values
  * `{:number, :date}` - a number with a date
  * `:grid` - a map of rows to maps of columns to cells
  * `:upload` - `{:upload, name}`
  * `:geolocation` - `{latitude, longitude}`

# `wide_row`

```elixir
@type wide_row() :: %{
  :participant_id =&gt; String.t(),
  :site_id =&gt; String.t() | nil,
  :source =&gt; context(),
  :instance_id =&gt; String.t() | nil,
  :parent_id =&gt; String.t() | nil,
  optional(String.t()) =&gt; CastorEDC.FieldValue.t() | boolean()
}
```

A participant's study values, or a repeating data or survey instance's
values, as `data_points/3` gives them with `format: :wide`: the keys of
`t:row/0` that say whose values they are, and a value for each variable,
under its name.

# `data_points`

```elixir
@spec data_points(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(row() | wide_row())
```

Streams the study's values as `t:row/0`s, one per value.

The stream fetches the schema and the participants (for their sites)
when it starts, then each source's values page by page, as it's
consumed. A failed request raises `CastorEDC.Error` where the stream is
consumed.

## Options

  * `:format` - `:long` (the default) or `:wide`, see below
  * `:sources` - the sources to include, all of `[:study,
    :repeating_data, :survey]` by default
  * `:schema` - the result of `schema/2`, if you already have it

## Wide format

With `format: :wide`, the stream has a `t:wide_row/0` for each
participant with study values, and for each repeating data instance and
survey instance with values. Besides `:participant_id`, `:site_id`,
`:source`, `:instance_id` and `:parent_id`, each has a key for every
variable of its study, repeating data or survey (in the schema), with
the variable name as a string and `nil` where there's no value. Rows of
the same repeating data or survey share their keys, so each such group
makes a table.

A checkbox field becomes a column per option, named
`<variable>_<option value>`: `true` when checked, `false` when not, and
the field's value (`nil`, a `CastorEDC.MissingValue` or `:encrypted`)
when there's no list of checked options. A field without a variable name
is keyed by its ID, and so are both columns when two would share a name
(such as a checkbox `sym` with option `1` and a field `sym_1`):
`<field ID>` or `<field ID>_<option value>`. Fields on no form the study
knows count as the study's own, and values of fields the schema doesn't
know are left out.

The wide format has to see every value before it can build a row, so the
stream fetches them all when it starts.

# `schema`

```elixir
@spec schema(CastorEDC.client(), String.t()) ::
  {:ok, %{required(String.t()) =&gt; column()}} | {:error, CastorEDC.Error.t()}
```

Describes the study's fields, as a map of field IDs to `t:column/0`s.

Fields that only lay out a form, such as remarks, are left out. Fields of
a type the client doesn't know have type `:string`.

It fetches every field with its option group, and every form: the
study's, and those of each repeating data and survey, since only a
field's form says where it collects data.

# `value_type`

```elixir
@spec value_type(String.t()) :: value_type()
```

The Elixir type of a field type's values, as in `t:value_type/0`.

    iex> CastorEDC.Tabular.value_type("numeric")
    :number
    iex> CastorEDC.Tabular.value_type("checkbox")
    {:list, :string}

---

*Consult [api-reference.md](api-reference.md) for complete listing*
