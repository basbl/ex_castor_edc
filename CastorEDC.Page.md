# `CastorEDC.Page`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/page.ex#L1)

One page of a collection.

Every `list_` operation returns a page, whether the API pages that
collection or not; a collection the API returns whole is page 1 of 1. The
`stream_` operations walk every page and return the entries themselves.

An empty collection is page 1 of 0, with no entries.

# `t`

```elixir
@type t() :: t(term())
```

# `t`

```elixir
@type t(entry) :: %CastorEDC.Page{
  entries: [entry],
  page: pos_integer(),
  page_count: non_neg_integer(),
  page_size: non_neg_integer(),
  total_items: non_neg_integer()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
