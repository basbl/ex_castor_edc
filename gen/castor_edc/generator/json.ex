defmodule CastorEDC.Generator.JSON do
  @moduledoc """
  Writes JSON for the files the generator keeps under version control.

  Keys are sorted and nested values indented by two spaces, so that a
  document fetched or built twice produces the same bytes, and a change to
  it shows up as a readable diff.
  """

  @doc """
  Encodes `value` as indented JSON with sorted keys, ending in a newline.
  """
  @spec encode!(term()) :: String.t()
  def encode!(value) do
    IO.iodata_to_binary([encode(value, 0), ?\n])
  end

  defp encode(map, _depth) when map == %{}, do: "{}"

  defp encode(map, depth) when is_map(map) do
    entries =
      map
      |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
      |> Enum.map(fn {key, value} ->
        [indent(depth + 1), JSON.encode!(to_string(key)), ": ", encode(value, depth + 1)]
      end)

    ["{\n", Enum.intersperse(entries, ",\n"), ?\n, indent(depth), ?}]
  end

  defp encode([], _depth), do: "[]"

  defp encode(list, depth) when is_list(list) do
    entries = Enum.map(list, &[indent(depth + 1), encode(&1, depth + 1)])

    ["[\n", Enum.intersperse(entries, ",\n"), ?\n, indent(depth), ?]]
  end

  defp encode(scalar, _depth), do: JSON.encode!(scalar)

  defp indent(depth), do: String.duplicate("  ", depth)
end
