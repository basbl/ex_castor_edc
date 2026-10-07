defmodule CastorEDC.Generator.JSONPath do
  @moduledoc """
  The subset of JSONPath ([RFC 9535](https://www.rfc-editor.org/rfc/rfc9535))
  that the overlay needs to point at parts of the API spec.

  Supported:

    * the root `$`
    * child segments: `.name`, `['name']`, `["name"]`, `[0]`, `[-1]`
    * wildcards: `.*` and `[*]`
    * filters: `[?<expression>]`, where an expression compares singular
      queries and literals (`==`, `!=`, `<`, `<=`, `>`, `>=`), tests for
      existence (`@.deprecated`, or a nested filter such as
      `@.tags[?@ == 'beta']`), and combines those with `&&`, `||`, `!` and
      parentheses

  Descendant segments (`..`), slices and function extensions aren't
  supported. A node is returned as `{path, value}`, where `path` is the list
  of map keys and list indexes that leads to it from the root.
  """

  @type path :: [String.t() | non_neg_integer()]
  @type segment ::
          {:child, String.t()} | {:index, integer()} | :wildcard | {:filter, expression()}
  @type expression :: term()

  @doc """
  Parses a JSONPath query into segments, raising `ArgumentError` when the
  query is invalid or uses something this module doesn't support.
  """
  @spec parse!(String.t()) :: [segment()]
  def parse!("$" <> rest) do
    case segments(rest, []) do
      {segments, ""} -> segments
      {_segments, rest} -> raise ArgumentError, "unexpected #{inspect(rest)} in JSONPath"
    end
  end

  def parse!(query), do: raise(ArgumentError, "a JSONPath query starts with $, got: #{inspect(query)}")

  @doc """
  Returns the nodes of `document` that `query` selects, in document order
  (map keys sorted, so the order is stable).
  """
  @spec select(term(), String.t() | [segment()]) :: [{path(), term()}]
  def select(document, query) when is_binary(query), do: select(document, parse!(query))

  def select(document, segments) when is_list(segments) do
    select_from([{[], document}], segments, document)
  end

  defp select_from(nodes, [], _root), do: nodes

  defp select_from(nodes, [segment | segments], root) do
    nodes
    |> Enum.flat_map(fn node -> apply_segment(node, segment, root) end)
    |> select_from(segments, root)
  end

  defp apply_segment({path, map}, {:child, name}, _root) when is_map(map) do
    case Map.fetch(map, name) do
      {:ok, value} -> [{path ++ [name], value}]
      :error -> []
    end
  end

  defp apply_segment({path, list}, {:index, index}, _root) when is_list(list) do
    index = if index < 0, do: length(list) + index, else: index

    case Enum.fetch(list, index) do
      {:ok, value} when index >= 0 -> [{path ++ [index], value}]
      _out_of_range -> []
    end
  end

  defp apply_segment(node, :wildcard, _root), do: children(node)

  defp apply_segment(node, {:filter, expression}, root) do
    Enum.filter(children(node), fn {_path, value} -> truthy?(expression, value, root) end)
  end

  defp apply_segment(_node, _segment, _root), do: []

  defp children({path, map}) when is_map(map) do
    map |> Enum.sort_by(&elem(&1, 0)) |> Enum.map(fn {key, value} -> {path ++ [key], value} end)
  end

  defp children({path, list}) when is_list(list) do
    list |> Enum.with_index() |> Enum.map(fn {value, index} -> {path ++ [index], value} end)
  end

  defp children(_scalar), do: []

  # Filter evaluation

  defp truthy?({:or, left, right}, current, root), do: truthy?(left, current, root) or truthy?(right, current, root)
  defp truthy?({:and, left, right}, current, root), do: truthy?(left, current, root) and truthy?(right, current, root)
  defp truthy?({:not, expression}, current, root), do: not truthy?(expression, current, root)
  defp truthy?({:exists, query}, current, root), do: run_query(query, current, root) != []

  defp truthy?({:compare, operator, left, right}, current, root) do
    compare(operator, operand(left, current, root), operand(right, current, root))
  end

  defp run_query({:current, segments}, current, root), do: select_from([{[], current}], segments, root)
  defp run_query({:root, segments}, _current, root), do: select_from([{[], root}], segments, root)

  defp operand({:literal, value}, _current, _root), do: {:value, value}

  defp operand(query, current, root) do
    case run_query(query, current, root) do
      [{_path, value}] -> {:value, value}
      _nothing_or_many -> :nothing
    end
  end

  defp compare(:==, left, right), do: left == right
  defp compare(:!=, left, right), do: left != right
  defp compare(operator, {:value, left}, {:value, right}), do: ordered(operator, left, right)
  defp compare(_operator, _left, _right), do: false

  defp ordered(operator, left, right)
       when (is_number(left) and is_number(right)) or (is_binary(left) and is_binary(right)) do
    case operator do
      :< -> left < right
      :<= -> left <= right
      :> -> left > right
      :>= -> left >= right
    end
  end

  defp ordered(_operator, _left, _right), do: false

  # Parsing: segments

  defp segments(".*" <> rest, acc), do: segments(rest, [:wildcard | acc])

  defp segments("." <> rest, acc) do
    {name, rest} = member_name(rest)
    segments(rest, [{:child, name} | acc])
  end

  defp segments("[" <> rest, acc) do
    {segment, rest} = rest |> skip_space() |> bracket()
    segments(rest, [segment | acc])
  end

  defp segments(rest, acc), do: {Enum.reverse(acc), rest}

  defp member_name(string) do
    case Regex.run(~r/^[A-Za-z_][A-Za-z0-9_\-]*/, string) do
      [name] -> {name, drop_prefix(string, name)}
      nil -> raise ArgumentError, "expected a member name in JSONPath at #{inspect(string)}"
    end
  end

  defp bracket("*" <> rest), do: {:wildcard, close_bracket(rest)}

  defp bracket("?" <> rest) do
    {expression, rest} = rest |> skip_space() |> or_expression()
    {{:filter, expression}, close_bracket(rest)}
  end

  defp bracket(<<quote, _rest::binary>> = string) when quote in [?', ?"] do
    {name, rest} = string_literal(string)
    {{:child, name}, close_bracket(rest)}
  end

  defp bracket(string) do
    case Integer.parse(string) do
      {index, rest} -> {{:index, index}, close_bracket(rest)}
      :error -> raise ArgumentError, "unsupported selector in JSONPath at #{inspect(string)}"
    end
  end

  defp close_bracket(string) do
    case skip_space(string) do
      "]" <> rest -> rest
      other -> raise ArgumentError, "expected ] in JSONPath at #{inspect(other)}"
    end
  end

  # Parsing: filter expressions

  defp or_expression(string) do
    {left, rest} = and_expression(string)

    case skip_space(rest) do
      "||" <> rest ->
        {right, rest} = rest |> skip_space() |> or_expression()
        {{:or, left, right}, rest}

      rest ->
        {left, rest}
    end
  end

  defp and_expression(string) do
    {left, rest} = unary(string)

    case skip_space(rest) do
      "&&" <> rest ->
        {right, rest} = rest |> skip_space() |> and_expression()
        {{:and, left, right}, rest}

      rest ->
        {left, rest}
    end
  end

  defp unary("!" <> rest) do
    {expression, rest} = rest |> skip_space() |> unary()
    {{:not, expression}, rest}
  end

  defp unary("(" <> rest) do
    {expression, rest} = rest |> skip_space() |> or_expression()

    case skip_space(rest) do
      ")" <> rest -> {expression, rest}
      other -> raise ArgumentError, "expected ) in JSONPath filter at #{inspect(other)}"
    end
  end

  defp unary(string) do
    {left, rest} = comparable(string)

    case comparison_operator(skip_space(rest)) do
      {operator, rest} ->
        {right, rest} = rest |> skip_space() |> comparable()
        {{:compare, operator, left, right}, rest}

      nil ->
        case left do
          {:literal, _value} -> raise ArgumentError, "a JSONPath filter can't test a literal"
          query -> {{:exists, query}, rest}
        end
    end
  end

  defp comparison_operator("==" <> rest), do: {:==, rest}
  defp comparison_operator("!=" <> rest), do: {:!=, rest}
  defp comparison_operator("<=" <> rest), do: {:<=, rest}
  defp comparison_operator(">=" <> rest), do: {:>=, rest}
  defp comparison_operator("<" <> rest), do: {:<, rest}
  defp comparison_operator(">" <> rest), do: {:>, rest}
  defp comparison_operator(_string), do: nil

  defp comparable("@" <> rest) do
    {segments, rest} = segments(rest, [])
    {{:current, segments}, rest}
  end

  defp comparable("$" <> rest) do
    {segments, rest} = segments(rest, [])
    {{:root, segments}, rest}
  end

  defp comparable("true" <> rest), do: {{:literal, true}, rest}
  defp comparable("false" <> rest), do: {{:literal, false}, rest}
  defp comparable("null" <> rest), do: {{:literal, nil}, rest}

  defp comparable(<<quote, _rest::binary>> = string) when quote in [?', ?"] do
    {value, rest} = string_literal(string)
    {{:literal, value}, rest}
  end

  defp comparable(string) do
    case Regex.run(~r/^-?\d+(\.\d+)?([eE][+-]?\d+)?/, string) do
      [number | _groups] ->
        {{:literal, parse_number(number)}, drop_prefix(string, number)}

      nil ->
        raise ArgumentError, "unexpected #{inspect(string)} in JSONPath filter"
    end
  end

  defp string_literal(<<quote, rest::binary>>), do: string_literal(rest, quote, [])

  defp string_literal(<<?\\, char, rest::binary>>, quote, acc), do: string_literal(rest, quote, [char | acc])
  defp string_literal(<<quote, rest::binary>>, quote, acc), do: {acc |> Enum.reverse() |> List.to_string(), rest}
  defp string_literal(<<char::utf8, rest::binary>>, quote, acc), do: string_literal(rest, quote, [char | acc])
  defp string_literal("", _quote, _acc), do: raise(ArgumentError, "unterminated string in JSONPath")

  defp parse_number(number) do
    case Integer.parse(number) do
      {integer, ""} ->
        integer

      _not_an_integer ->
        {float, ""} = Float.parse(number)
        float
    end
  end

  defp drop_prefix(string, prefix), do: binary_part(string, byte_size(prefix), byte_size(string) - byte_size(prefix))

  defp skip_space(string), do: String.trim_leading(string)
end
