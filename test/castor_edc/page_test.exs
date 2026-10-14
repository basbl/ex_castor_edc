defmodule CastorEDC.PageTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Page

  test "takes a paged collection's counters" do
    body = %{"page" => 2, "page_count" => 3, "page_size" => 25, "total_items" => 61}

    assert Page.from_body(body, [:a]) == %Page{entries: [:a], page: 2, page_count: 3, page_size: 25, total_items: 61}
  end

  test "turns the API's page 0 of an empty collection into page 1 of 0" do
    body = %{"page" => 0, "page_count" => 0, "page_size" => 25, "total_items" => 0}

    assert Page.from_body(body, []) == %Page{entries: [], page: 1, page_count: 0, page_size: 25, total_items: 0}
  end

  test "makes a collection returned whole page 1 of 1" do
    assert Page.from_body(%{"total_items" => 2}, [:a, :b]) ==
             %Page{entries: [:a, :b], page: 1, page_count: 1, page_size: 2, total_items: 2}
  end

  test "reads the totals of collections that aren't HAL" do
    assert Page.from_body(%{"totals" => 250}, [:a]).total_items == 250
    assert Page.from_body(%{"total" => 0}, []).total_items == 0
    assert Page.from_body(%{}, [:a, :b]).total_items == 2
  end

  test "empty/0 is page 1 of 0" do
    assert Page.empty() == %Page{entries: [], page: 1, page_count: 0, page_size: 0, total_items: 0}
  end
end
