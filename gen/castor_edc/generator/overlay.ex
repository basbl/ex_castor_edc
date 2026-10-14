defmodule CastorEDC.Generator.Overlay do
  @moduledoc """
  Applies an [OpenAPI Overlay](https://spec.openapis.org/overlay/v1.0.0.html)
  to a document.

  The overlay holds our corrections to the upstream API spec, as a list of
  actions applied in order. Each action selects nodes with a JSONPath
  `target` (see `CastorEDC.Generator.JSONPath` for the supported subset)
  and either removes them or merges an update into them:

      %{
        "overlay" => "1.0.0",
        "info" => %{"title" => "Castor EDC API corrections", "version" => "1"},
        "actions" => [
          %{
            "target" => "$.paths.*[?@.deprecated == true]",
            "description" => "Deprecated operations aren't part of the client.",
            "remove" => true
          }
        ]
      }

  An `update` is deep-merged into an object it selects, and appended to an
  array it selects, as the specification describes. An action whose target
  selects nothing raises: it means the upstream spec changed under the
  correction, and the correction needs another look.
  """

  alias CastorEDC.Generator.JSONPath

  @doc """
  Applies every action of `overlay` to `document`, in order.
  """
  @spec apply!(map(), map()) :: map()
  def apply!(document, %{"actions" => actions}) when is_list(actions) do
    Enum.reduce(actions, document, &apply_action!/2)
  end

  def apply!(_document, overlay) do
    raise ArgumentError, "an overlay needs a list of actions, got: #{inspect(overlay, limit: 5)}"
  end

  defp apply_action!(%{"target" => target} = action, document) do
    nodes = JSONPath.select(document, target)

    if nodes == [] do
      raise ArgumentError, """
      overlay target #{target} selects nothing.
      The upstream spec has probably changed; check the action:

      #{action["description"] || "(no description)"}
      """
    end

    paths = Enum.map(nodes, &elem(&1, 0))

    case action do
      %{"remove" => true} -> remove_all(document, paths)
      %{"update" => update} -> Enum.reduce(paths, document, &update_at(&2, &1, update))
      _other -> raise ArgumentError, "overlay action on #{target} needs `remove: true` or an `update`"
    end
  end

  defp apply_action!(action, _document) do
    raise ArgumentError, "overlay action without a target: #{inspect(action)}"
  end

  # Removing from the deepest and highest list index first keeps the paths of
  # the nodes still to be removed valid.
  defp remove_all(document, paths) do
    paths
    |> Enum.sort(:desc)
    |> Enum.reduce(document, &remove_at(&2, &1))
  end

  defp remove_at(map, [key]) when is_map(map), do: Map.delete(map, key)
  defp remove_at(list, [index]) when is_list(list), do: List.delete_at(list, index)
  defp remove_at(container, [key | path]), do: change_child(container, key, &remove_at(&1, path))

  defp update_at(node, [], update), do: merge(node, update)
  defp update_at(container, [key | path], update), do: change_child(container, key, &update_at(&1, path, update))

  defp change_child(map, key, fun) when is_map(map), do: Map.update!(map, key, fun)
  defp change_child(list, index, fun) when is_list(list), do: List.update_at(list, index, fun)

  defp merge(target, update) when is_map(target) and is_map(update) do
    Map.merge(target, update, fn _key, current, new -> deep_merge(current, new) end)
  end

  defp merge(target, update) when is_list(target), do: target ++ [update]

  defp merge(target, update) do
    raise ArgumentError,
          "an overlay update must be an object to merge into an object; " <>
            "got #{inspect(update, limit: 5)} for #{inspect(target, limit: 5)}"
  end

  defp deep_merge(current, new) when is_map(current) and is_map(new) do
    Map.merge(current, new, fn _key, current, new -> deep_merge(current, new) end)
  end

  defp deep_merge(_current, new), do: new
end
