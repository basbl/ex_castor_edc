defmodule CastorEDC.PartialDate do
  @moduledoc """
  A date whose day, or day and month, may be unknown.

  Fields of type `date_partial` store unknown parts as `00`, such as
  `"00-05-2020"` for May 2020. `CastorEDC.FieldValue.decode/2` turns their
  values into this struct, with `nil` for the parts that are unknown,
  whether or not the date is complete.
  """

  @enforce_keys [:year]
  defstruct [:year, month: nil, day: nil]

  @type t :: %__MODULE__{year: integer(), month: 1..12 | nil, day: 1..31 | nil}

  @doc """
  Builds a partial date, checking that the known parts form a valid date.

      iex> CastorEDC.PartialDate.new(2020, 5, nil)
      {:ok, %CastorEDC.PartialDate{year: 2020, month: 5, day: nil}}
      iex> CastorEDC.PartialDate.new(2020, 2, 30)
      {:error, :invalid_date}
      iex> CastorEDC.PartialDate.new(2020, nil, 3)
      {:error, :invalid_date}
  """
  @spec new(integer(), 1..12 | nil, 1..31 | nil) :: {:ok, t()} | {:error, :invalid_date}
  def new(year, month, day) do
    valid? =
      case {month, day} do
        {nil, nil} -> true
        {month, nil} -> month in 1..12
        {nil, _day} -> false
        {month, day} -> match?({:ok, _date}, Date.new(year, month, day))
      end

    if valid?, do: {:ok, %__MODULE__{year: year, month: month, day: day}}, else: {:error, :invalid_date}
  end

  @doc """
  The date, when every part is known.

      iex> CastorEDC.PartialDate.to_date(%CastorEDC.PartialDate{year: 2020, month: 5, day: 3})
      {:ok, ~D[2020-05-03]}
      iex> CastorEDC.PartialDate.to_date(%CastorEDC.PartialDate{year: 2020, month: 5})
      :error
  """
  @spec to_date(t()) :: {:ok, Date.t()} | :error
  def to_date(%__MODULE__{year: year, month: month, day: day}) when is_integer(month) and is_integer(day),
    do: Date.new(year, month, day)

  def to_date(%__MODULE__{}), do: :error

  @doc """
  The ISO 8601 form, which leaves unknown parts out.

      iex> CastorEDC.PartialDate.to_iso8601(%CastorEDC.PartialDate{year: 2020, month: 5})
      "2020-05"
      iex> CastorEDC.PartialDate.to_iso8601(%CastorEDC.PartialDate{year: 2020})
      "2020"
  """
  @spec to_iso8601(t()) :: String.t()
  def to_iso8601(%__MODULE__{year: year, month: month, day: day}) do
    [year |> Integer.to_string() |> String.pad_leading(4, "0"), month, day]
    |> Enum.reject(&is_nil/1)
    |> Enum.map_join("-", fn
      part when is_integer(part) -> part |> Integer.to_string() |> String.pad_leading(2, "0")
      part -> part
    end)
  end

  defimpl String.Chars do
    def to_string(partial_date), do: CastorEDC.PartialDate.to_iso8601(partial_date)
  end
end
