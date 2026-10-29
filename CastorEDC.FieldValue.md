# `CastorEDC.FieldValue`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/field_value.ex#L1)

Turns the values of data points into Elixir values.

The API sends every value as a string, the way it's stored, whatever the
field's type. `decode/2` reads it according to the field's type:

| Field type | Stored as | Decoded to |
| --- | --- | --- |
| `numeric`, `slider` | `"42"`, `"3.14"` | an integer or a float |
| `year` | `"2015"` | an integer |
| `calculation` | the result | a number when it is one, otherwise the string |
| `date` | `"07-10-2026"`, or `"07102026"` in older data | a `Date` |
| `date_partial` | `"00-05-2020"`, with `00` for unknown parts | a `CastorEDC.PartialDate` |
| `time` | `"12:30"` | a `Time` |
| `datetime` | `"07-10-2026;12:30"` | a `NaiveDateTime` |
| `numberdate` | `"5;07-10-2026"` | `{number, date}`, either of which can be `nil` |
| `radio`, `dropdown` | the chosen option's value, such as `"2"` | the value, as a string |
| `checkbox` | the checked options' values, such as `"0;1"` | a list of the values |
| `grid` (the API doesn't take grid values in writes) | JSON, row by column: `{"0":{"0":"5"}}` | `%{row => %{column => cell}}`, with integer rows and columns; given the field, each cell decoded by its row's or column's type from the grid's layout, and like text otherwise |
| `upload` | `"-- Uploaded File: scan.pdf --"` from single data points, `"- - Uploaded file - -"` when the name can't be read, or JSON with the name base64-encoded (`{"file_name":"c2Nhbi5wZGY=",...}`) from the lists | `{:upload, name}`, with `nil` for an unknown name |
| `geolocation` | `"52.36;4.90"` | `{latitude, longitude}` |
| `string`, `textarea` and others | text | the string |
| any, when empty | `""` | `nil` |
| any, when marked missing | `"##USER_MISSING_95##"` to `"##USER_MISSING_99##"` | a `CastorEDC.MissingValue` |
| any, when encrypted | `"*encrypted*"` | `:encrypted` |

Layout types without values, such as `remark` and `repeated_measures`,
decode like text.

Options are stored by value, not by name: `label/2` looks up the name the
user saw.

`decode/2` never raises. A value that doesn't read as its type comes back
as the string it arrived as, and the first such value of each field logs
a warning.

# `t`

```elixir
@type t() ::
  nil
  | String.t()
  | integer()
  | float()
  | Date.t()
  | CastorEDC.PartialDate.t()
  | Time.t()
  | NaiveDateTime.t()
  | {integer() | float() | nil, Date.t() | nil}
  | [String.t()]
  | %{
      optional(integer() | String.t()) =&gt; %{
        optional(integer() | String.t()) =&gt;
          String.t() | CastorEDC.MissingValue.t() | :encrypted | nil
      }
    }
  | {:upload, String.t() | nil}
  | {float(), float()}
  | CastorEDC.MissingValue.t()
  | :encrypted
```

# `decode`

```elixir
@spec decode(String.t() | nil, CastorEDC.Model.Field.t() | String.t() | atom()) :: t()
```

Decodes a stored value for the field it belongs to.

`field` is a `CastorEDC.Model.Field`, or just its type, such as
`"numeric"`.

    iex> CastorEDC.FieldValue.decode("42", "numeric")
    42
    iex> CastorEDC.FieldValue.decode("##USER_MISSING_96##", "numeric")
    %CastorEDC.MissingValue{code: 96, reason: :not_applicable}
    iex> CastorEDC.FieldValue.decode("", "year")
    nil

# `label`

```elixir
@spec label(
  String.t() | [String.t()],
  CastorEDC.Model.FieldOptionGroup.t() | CastorEDC.Model.Field.t() | nil
) :: String.t() | [String.t() | nil] | nil
```

The name of the option with the given value, as the user saw it.

`options` is the field's `CastorEDC.Model.FieldOptionGroup`, or the field
itself when it was listed with `include: "optiongroup"`. A list of values,
as a checkbox field has, gives a list of names. A value the option group
doesn't have gives `nil`.

    iex> yes = %CastorEDC.Model.FieldOption{value: "1", name: "Yes"}
    iex> no = %CastorEDC.Model.FieldOption{value: "0", name: "No"}
    iex> group = %CastorEDC.Model.FieldOptionGroup{options: [yes, no]}
    iex> CastorEDC.FieldValue.label("1", group)
    "Yes"
    iex> CastorEDC.FieldValue.label(["0", "1"], group)
    ["No", "Yes"]

---

*Consult [api-reference.md](api-reference.md) for complete listing*
