defmodule CastorEDC.Page do
  @moduledoc """
  One page of a collection.

  Every `list_` operation returns a page, whether the API pages that
  collection or not; a collection the API returns whole is page 1 of 1. The
  `stream_` operations walk every page and return the entries themselves.

  An empty collection is page 1 of 0, with no entries.
  """

  @enforce_keys [:entries]
  defstruct entries: [], page: 1, page_count: 1, page_size: 0, total_items: 0

  @type t(entry) :: %__MODULE__{
          entries: [entry],
          page: pos_integer(),
          page_count: non_neg_integer(),
          page_size: non_neg_integer(),
          total_items: non_neg_integer()
        }

  @type t :: t(term())

  @doc false
  @spec empty() :: t()
  def empty, do: %__MODULE__{entries: [], page: 1, page_count: 0, page_size: 0, total_items: 0}

  @doc false
  # Builds a page from a response body and the records found in it. Paged
  # collections carry their own counters; collections returned whole only
  # have a total (`total_items`, or `totals` and `total` on the two that
  # aren't HAL), and empty paged collections claim to be page 0.
  @spec from_body(map(), list()) :: t()
  def from_body(body, entries) do
    total = integer(body["total_items"] || body["totals"] || body["total"]) || length(entries)

    case {integer(body["page"]), integer(body["page_count"])} do
      {page, page_count} when is_integer(page) and is_integer(page_count) ->
        %__MODULE__{
          entries: entries,
          page: max(page, 1),
          page_count: page_count,
          page_size: integer(body["page_size"]) || length(entries),
          total_items: total
        }

      _unpaged ->
        %__MODULE__{
          entries: entries,
          page: 1,
          page_count: if(entries == [], do: 0, else: 1),
          page_size: length(entries),
          total_items: total
        }
    end
  end

  defp integer(value) when is_integer(value), do: value
  defp integer(value) when is_float(value), do: trunc(value)

  defp integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _other -> nil
    end
  end

  defp integer(_value), do: nil
end
