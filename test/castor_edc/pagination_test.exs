defmodule CastorEDC.PaginationTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Error
  alias CastorEDC.Page
  alias CastorEDC.Pagination

  # A collection of `total` numbers, served `size` per page, reporting each
  # fetch to the test process.
  defp collection(total, test \\ self()) do
    fn options ->
      send(test, {:fetched, options})
      size = options[:page_size] || 2
      page = options[:page]
      page_count = div(total + size - 1, size)
      entries = Enum.slice(1..total//1, (page - 1) * size, size)

      {:ok, %Page{entries: entries, page: page, page_count: page_count, page_size: size, total_items: total}}
    end
  end

  test "walks every page and returns the entries" do
    assert 5 |> collection() |> Pagination.stream() |> Enum.to_list() == [1, 2, 3, 4, 5]

    assert_received {:fetched, [page: 1]}
    assert_received {:fetched, [page: 2]}
    assert_received {:fetched, [page: 3]}
    refute_received {:fetched, _options}
  end

  test "fetches nothing until consumed, and only the pages consumed" do
    stream = Pagination.stream(collection(10))
    refute_received {:fetched, _options}

    assert Enum.take(stream, 3) == [1, 2, 3]
    assert_received {:fetched, [page: 1]}
    assert_received {:fetched, [page: 2]}
    refute_received {:fetched, _options}
  end

  test "uses the operation's largest page size unless the caller gives one" do
    assert 5 |> collection() |> Pagination.stream([], 1000) |> Enum.to_list() == [1, 2, 3, 4, 5]
    assert_received {:fetched, [page: 1, page_size: 1000]}
    refute_received {:fetched, _options}

    5 |> collection() |> Pagination.stream([page_size: 3], 1000) |> Enum.to_list()
    assert_received {:fetched, [page: 1, page_size: 3]}
    assert_received {:fetched, [page: 2, page_size: 3]}
  end

  test "starts at the caller's page" do
    assert 5 |> collection() |> Pagination.stream(page: 2) |> Enum.to_list() == [3, 4, 5]
  end

  test "stops at an empty collection or page" do
    assert 0 |> collection() |> Pagination.stream() |> Enum.to_list() == []

    empty_page = fn _options -> {:ok, %Page{entries: [], page: 1, page_count: 5}} end
    assert empty_page |> Pagination.stream() |> Enum.to_list() == []
  end

  test "raises a failed page's error where the stream is consumed" do
    failing = fn
      [page: 1] -> {:ok, %Page{entries: [1, 2], page: 1, page_count: 3}}
      [page: 2] -> {:error, %Error{message: "Too many requests", status: 429}}
    end

    stream = Pagination.stream(failing)

    assert_raise Error, "Too many requests", fn -> Enum.to_list(stream) end
  end
end
