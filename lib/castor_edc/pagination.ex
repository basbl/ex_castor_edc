defmodule CastorEDC.Pagination do
  @moduledoc """
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
  """

  alias CastorEDC.Page

  @doc """
  Streams the entries of every page `fetch` returns.

  `fetch` takes the options for one page (`page:` and `page_size:`) and
  returns what a `list_` function returns. `options` are the caller's
  options, read for `:page` and `:page_size`; `max_page_size` is the
  operation's largest page size, used when the caller gives none.
  """
  @spec stream((keyword() -> {:ok, Page.t()} | {:error, CastorEDC.Error.t()}), keyword(), pos_integer() | nil) ::
          Enumerable.t()
  def stream(fetch, options \\ [], max_page_size \\ nil) do
    page_size = options[:page_size] || max_page_size

    Stream.resource(
      fn -> options[:page] || 1 end,
      fn
        :done -> {:halt, :done}
        page -> fetch_page(fetch, page, page_size)
      end,
      fn _state -> :ok end
    )
  end

  defp fetch_page(fetch, page, page_size) do
    options = if page_size, do: [page: page, page_size: page_size], else: [page: page]

    case fetch.(options) do
      {:ok, %Page{entries: []}} -> {:halt, :done}
      {:ok, %Page{entries: entries, page: current, page_count: count}} when current >= count -> {entries, :done}
      {:ok, %Page{entries: entries, page: current}} -> {entries, current + 1}
      {:error, error} -> raise error
    end
  end
end
