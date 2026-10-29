# `CastorEDC.PartialDate`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/partial_date.ex#L1)

A date whose day, or day and month, may be unknown.

Fields of type `date_partial` store unknown parts as `00`, such as
`"00-05-2020"` for May 2020. `CastorEDC.FieldValue.decode/2` turns their
values into this struct, with `nil` for the parts that are unknown,
whether or not the date is complete.

# `t`

```elixir
@type t() :: %CastorEDC.PartialDate{
  day: 1..31 | nil,
  month: 1..12 | nil,
  year: integer()
}
```

# `new`

```elixir
@spec new(integer(), 1..12 | nil, 1..31 | nil) :: {:ok, t()} | {:error, :invalid_date}
```

Builds a partial date, checking that the known parts form a valid date.

    iex> CastorEDC.PartialDate.new(2020, 5, nil)
    {:ok, %CastorEDC.PartialDate{year: 2020, month: 5, day: nil}}
    iex> CastorEDC.PartialDate.new(2020, 2, 30)
    {:error, :invalid_date}
    iex> CastorEDC.PartialDate.new(2020, nil, 3)
    {:error, :invalid_date}

# `to_date`

```elixir
@spec to_date(t()) :: {:ok, Date.t()} | :error
```

The date, when every part is known.

    iex> CastorEDC.PartialDate.to_date(%CastorEDC.PartialDate{year: 2020, month: 5, day: 3})
    {:ok, ~D[2020-05-03]}
    iex> CastorEDC.PartialDate.to_date(%CastorEDC.PartialDate{year: 2020, month: 5})
    :error

# `to_iso8601`

```elixir
@spec to_iso8601(t()) :: String.t()
```

The ISO 8601 form, which leaves unknown parts out.

    iex> CastorEDC.PartialDate.to_iso8601(%CastorEDC.PartialDate{year: 2020, month: 5})
    "2020-05"
    iex> CastorEDC.PartialDate.to_iso8601(%CastorEDC.PartialDate{year: 2020})
    "2020"

---

*Consult [api-reference.md](api-reference.md) for complete listing*
