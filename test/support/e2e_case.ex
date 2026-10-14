defmodule CastorEDC.E2ECase do
  @moduledoc """
  End-to-end tests against a Castor EDC test study.

  They're excluded from `mix test`; run them with the test study's
  configuration in the environment (see `CastorEDC.TestStudy`):

      $ mix test --only e2e

  The study may be transient. On the first run, `mix castor_edc.e2e.seed`
  fills it with a participant and data, and records what it created in
  `test/e2e/.seeded/<study ID>.json`; every other ID comes from the study's own
  collections. Delete that file to seed again.
  """

  use ExUnit.CaseTemplate

  import ExUnit.Assertions

  alias CastorEDC.Generator.JSON, as: GeneratorJSON
  alias CastorEDC.TestStudy
  alias Mix.Tasks.CastorEdc.E2e.Seed

  using do
    quote do
      import CastorEDC.E2ECase

      @moduletag :e2e
      @moduletag timeout: 300_000
    end
  end

  setup_all do
    case TestStudy.missing() do
      [] -> :ok
      names -> raise "the end-to-end suite needs #{Enum.join(names, ", ")}; see CastorEDC.TestStudy"
    end

    %{client: client(), study: TestStudy.id(), ids: ids()}
  end

  @doc """
  A client for the test study, waiting out rate limits.
  """
  @spec client() :: Req.Request.t()
  def client, do: TestStudy.client(rate_limit: :wait, max_rate_limit_wait: 600_000)

  @doc """
  The IDs of the seeded data and of the study's own records, found once
  per test run.
  """
  @spec ids() :: map()
  def ids do
    case :persistent_term.get({__MODULE__, :ids}, nil) do
      nil ->
        seeded = seeded()

        ids =
          TestStudy.ids(client(), %{
            "study_id" => TestStudy.id(),
            "participant_id" => seeded["participant_id"],
            "site_id" => seeded["site_id"],
            "repeating_data_id" => seeded["repeating_data_id"],
            "repeating_data_instance_id" => seeded["repeating_data_instance_id"],
            "survey_package_instance_id" => seeded["survey_package_instance_id"],
            "survey_instance_id" => seeded["survey_instance_id"]
          })

        :persistent_term.put({__MODULE__, :ids}, Map.put(ids, "seeded", seeded))
        :persistent_term.get({__MODULE__, :ids})

      ids ->
        ids
    end
  end

  defp seeded do
    path = Seed.seeded_path()

    if not File.exists?(path) do
      seeded = Seed.seed(client(), TestStudy.id())
      File.mkdir_p!(Path.dirname(path))
      File.write!(path, GeneratorJSON.encode!(seeded))
    end

    path |> File.read!() |> JSON.decode!()
  end

  @doc """
  Asserts that no struct in `result`, at any depth, kept keys its spec
  doesn't describe.
  """
  def assert_described(result) do
    undescribed = result |> undescribed([]) |> Enum.uniq()
    assert undescribed == [], "keys the spec doesn't describe: #{inspect(undescribed)}"
  end

  defp undescribed(%CastorEDC.Page{entries: entries}, acc), do: undescribed(entries, acc)
  defp undescribed(list, acc) when is_list(list), do: Enum.reduce(list, acc, &undescribed/2)

  defp undescribed(%{__struct__: module, extra: extra} = struct, acc) do
    acc = if extra == %{}, do: acc, else: [{module, extra |> Map.keys() |> Enum.sort()} | acc]
    struct |> Map.from_struct() |> Map.delete(:extra) |> Map.values() |> undescribed(acc)
  end

  defp undescribed(_value, acc), do: acc
end
