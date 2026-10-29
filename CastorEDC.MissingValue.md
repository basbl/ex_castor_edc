# `CastorEDC.MissingValue`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/missing_value.ex#L1)

A value the user marked as missing, with the reason they gave.

Instead of a value, a field can hold one of five missing-data codes,
stored as `##USER_MISSING_95##` to `##USER_MISSING_99##`.
`CastorEDC.FieldValue.decode/2` turns them into this struct:

| Code | `reason` | Meaning |
| --- | --- | --- |
| 95 | `:measurement_failed` | Missing (measurement failed) |
| 96 | `:not_applicable` | Missing (not applicable) |
| 97 | `:not_asked` | Missing (not asked) |
| 98 | `:asked_but_unknown` | Missing (asked but unknown) |
| 99 | `:not_done` | Missing (not done) |

Exports write the codes as `-95` to `-99` in numeric columns, and as the
dates 1 January 2995 to 2999 in date columns.

# `reason`

```elixir
@type reason() ::
  :measurement_failed
  | :not_applicable
  | :not_asked
  | :asked_but_unknown
  | :not_done
```

# `t`

```elixir
@type t() :: %CastorEDC.MissingValue{code: 95..99, reason: reason()}
```

# `new`

```elixir
@spec new(integer()) :: t() | nil
```

The missing value with the given code, or `nil` for another code.

    iex> CastorEDC.MissingValue.new(98)
    %CastorEDC.MissingValue{code: 98, reason: :asked_but_unknown}

# `parse`

```elixir
@spec parse(String.t()) :: t() | nil
```

Reads a stored missing-value code, or returns `nil` for anything else.

    iex> CastorEDC.MissingValue.parse("##USER_MISSING_95##")
    %CastorEDC.MissingValue{code: 95, reason: :measurement_failed}
    iex> CastorEDC.MissingValue.parse("95")
    nil

# `to_wire`

```elixir
@spec to_wire(t()) :: String.t()
```

The stored form of a missing value, as written to the API.

    iex> CastorEDC.MissingValue.to_wire(CastorEDC.MissingValue.new(97))
    "##USER_MISSING_97##"

---

*Consult [api-reference.md](api-reference.md) for complete listing*
