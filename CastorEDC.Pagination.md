# `CastorEDC.Pagination`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/pagination.ex#L1)

Walks a paged collection page by page.

Every paged operation has a `stream_` function beside its `list_`
function, built on `stream/3`, which returns the records themselves:

    client
    |> CastorEDC.DataPoints.stream_study_data_points(study_id)
    |> Stream.filter(&(&1.participant_id in cohort))
    |> Enum.to_list()

Nothing is requested until the stream is consumed, and only as many pages
as the consumer asks for are fetched. Unless `:page_size` is given, every
page is as large as the API allows, so a walk takes as few requests as
possible, which also spares the rate limit.

The walk starts at `:page` (the first page by default) and stops after
the last page the API reports, or at an empty page.

## Failure

A stream can't return `{:error, _}` halfway, so a page that fails raises
its `CastorEDC.Error` where the stream is consumed. To handle that:

    try do
      Enum.to_list(stream)
    rescue
      error in CastorEDC.Error -> {:error, error}
    end

# `stream`

```elixir
@spec stream(
  (keyword() -&gt; {:ok, CastorEDC.Page.t()} | {:error, CastorEDC.Error.t()}),
  keyword(),
  pos_integer() | nil
) :: Enumerable.t()
```

Streams the entries of every page `fetch` returns.

`fetch` takes the options for one page (`page:` and `page_size:`) and
returns what a `list_` function returns. `options` are the caller's
options, read for `:page` and `:page_size`; `max_page_size` is the
operation's largest page size, used when the caller gives none.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
