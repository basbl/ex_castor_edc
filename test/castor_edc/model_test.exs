defmodule CastorEDC.ModelTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Model

  defmodule Thing do
    @moduledoc false
    defstruct [:id]
    def new(data), do: %__MODULE__{id: data["id"]}
  end

  test "one/2 and list/2 decode nested objects, passing anything else through" do
    assert Model.one(%{"id" => "1"}, Thing) == %Thing{id: "1"}
    assert Model.one(nil, Thing) == nil
    assert Model.one("not an object", Thing) == "not an object"

    assert Model.list([%{"id" => "1"}, %{"id" => "2"}], Thing) == [%Thing{id: "1"}, %Thing{id: "2"}]
    assert Model.list(nil, Thing) == nil
    assert Model.list(%{"id" => "1"}, Thing) == %{"id" => "1"}
  end

  test "casts integers" do
    assert Model.cast(5, :integer) == 5
    assert Model.cast(5.0, :integer) == 5
    assert Model.cast("5", :integer) == 5
    assert Model.cast(5.5, :integer) == 5.5
    assert Model.cast("five", :integer) == "five"
  end

  test "casts data point timestamps to naive datetimes" do
    assert Model.cast("2026-10-07 21:06:49", :naive_datetime) == ~N[2026-10-07 21:06:49]
    assert Model.cast("07-10-2026", :naive_datetime) == "07-10-2026"
  end

  test "casts the export list's PHP DateTime objects to datetimes in their zone" do
    value = %{"date" => "2026-10-07 21:08:46.000000", "timezone_type" => 3, "timezone" => "Europe/Amsterdam"}

    datetime = Model.cast(value, :datetime)

    assert datetime.time_zone == "Europe/Amsterdam"
    assert DateTime.to_naive(datetime) == ~N[2026-10-07 21:08:46.000000]

    assert datetime |> DateTime.shift_zone!("Etc/UTC", Tz.TimeZoneDatabase) |> DateTime.to_naive() ==
             ~N[2026-10-07 19:08:46.000000]
  end

  test "takes the earlier reading of an ambiguous local time" do
    # 02:30 happens twice in Amsterdam on 25 October 2026.
    value = %{"date" => "2026-10-25 02:30:00.000000", "timezone" => "Europe/Amsterdam"}

    assert Model.cast(value, :datetime).utc_offset + Model.cast(value, :datetime).std_offset == 7200
  end

  test "casts ISO 8601 strings to datetimes" do
    assert Model.cast("2026-10-07T19:08:46Z", :datetime) == ~U[2026-10-07 19:08:46Z]
  end

  test "never raises, returning what doesn't cast as it arrived" do
    odd = %{"date" => "not a date", "timezone" => "Europe/Amsterdam"}

    assert Model.cast(odd, :datetime) == odd

    assert Model.cast(%{"date" => "2026-10-07 21:08:46", "timezone" => "Mars/Olympus"}, :datetime)["timezone"] ==
             "Mars/Olympus"

    assert Model.cast(nil, :datetime) == nil
    assert Model.cast([1], :integer) == [1]
  end
end
