defmodule CastorEDC.PartialDateTest do
  use ExUnit.Case, async: true

  alias CastorEDC.PartialDate

  doctest PartialDate

  test "accepts a known year, an optional month and a day only with a month" do
    assert {:ok, %PartialDate{year: 2020, month: nil, day: nil}} = PartialDate.new(2020, nil, nil)
    assert {:ok, %PartialDate{day: 29}} = PartialDate.new(2020, 2, 29)
    assert {:error, :invalid_date} = PartialDate.new(2021, 2, 29)
    assert {:error, :invalid_date} = PartialDate.new(2020, 13, nil)
  end

  test "converts to a string in ISO 8601 form" do
    assert to_string(%PartialDate{year: 2020, month: 5, day: 3}) == "2020-05-03"
    assert to_string(%PartialDate{year: 987}) == "0987"
  end
end
