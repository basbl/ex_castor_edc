defmodule CastorEDC.E2E.ReadOperationsTest do
  @moduledoc """
  Every read operation answers, and its response decodes without leaving
  anything in a struct's `extra`.
  """

  use CastorEDC.E2ECase, async: false

  alias CastorEDC.TestStudy

  @spec_path "priv/openapi/castor_edc.json"
  @external_resource @spec_path

  for group <- CastorEDC.Generator.load!(@spec_path).groups,
      operation <- group.operations,
      operation.method == :get do
    @tag operation: operation.name
    test "#{inspect(group.module)}.#{operation.name}", %{client: client, ids: ids} do
      read(client, ids, unquote(group.module), unquote(Macro.escape(operation)))
    end
  end

  # Operations that need something a test study may not have.
  @needs %{"get_randomization" => "a randomized participant"}

  # Single data points need a field with a value in their context.
  @fields %{
    "get_study_data_point" => "study_field_id",
    "get_repeating_data_data_point" => "repeating_field_id",
    "get_survey_data_point" => "survey_field_id"
  }

  defp read(_client, _ids, _module, %{name: name}) when is_map_key(@needs, name) do
    IO.puts("\n#{name}: skipped, it needs #{@needs[name]}")
  end

  defp read(client, ids, module, operation) do
    ids =
      case ids["seeded"][@fields[operation.name]] do
        field_id when is_binary(field_id) -> Map.put(ids, "field_id", field_id)
        _no_field -> ids
      end

    case TestStudy.arguments(operation, ids) do
      {:ok, arguments} ->
        assert {:ok, result} = apply(module, String.to_atom(operation.name), [client | arguments] ++ [[]])
        if operation.decode, do: assert_described(result)

      :missing ->
        missing = for param <- operation.path_params, not Map.has_key?(ids, param.name), do: param.name
        IO.puts("\n#{operation.name}: skipped, the test study has nothing for #{Enum.join(missing, ", ")}")
    end
  end
end
