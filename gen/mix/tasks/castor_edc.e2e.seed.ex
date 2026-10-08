defmodule Mix.Tasks.CastorEdc.E2e.Seed do
  @shortdoc "Fills the Castor EDC test study with data for the end-to-end suite"

  @moduledoc """
  Fills the test study with a known data set through the API.

      $ mix castor_edc.e2e.seed

  It creates a participant on the study's first site, writes a value for
  every study field it can (and a user-missing value for one numeric
  field), creates a repeating data instance and writes its fields too, and
  creates a survey package instance (inviting an example.org address) with
  a value for one survey field.
  Every value carries the change reason `e2e <run id>`.

  A study that has never been live allows only ten participants; when the
  test study has them, the seed reuses its latest participant.

  Studies number their participants themselves, so the seed can't choose
  IDs; it records the ones it created in `test/e2e/.seeded/<study ID>.json`,
  which isn't committed. The end-to-end suite runs the seed when that file is
  missing.

  Configured through the environment; see `CastorEDC.TestStudy`.
  """

  use Mix.Task

  alias CastorEDC.DataPoints
  alias CastorEDC.Fields
  alias CastorEDC.Forms
  alias CastorEDC.Generator.JSON
  alias CastorEDC.Participants
  alias CastorEDC.RepeatingData
  alias CastorEDC.Sites
  alias CastorEDC.Surveys
  alias CastorEDC.TestStudy

  @doc false
  # One file per study, so switching between test studies (on different
  # servers, say) never mixes up their IDs.
  def seeded_path, do: Path.join("test/e2e/.seeded", TestStudy.id() <> ".json")

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    case TestStudy.missing() do
      [] -> :ok
      [name | _rest] -> Mix.raise("#{name} isn't set; see `mix help castor_edc.e2e.seed`")
    end

    seeded = seed(TestStudy.client(), TestStudy.id())
    File.mkdir_p!(Path.dirname(seeded_path()))
    File.write!(seeded_path(), JSON.encode!(seeded))

    Mix.shell().info(
      "Seeded participant #{seeded["participant_id"]}: #{seeded["study_values"]} study values, " <>
        "#{seeded["repeating_data_values"]} repeating data values"
    )
  end

  @doc false
  def seed(client, study) do
    run_id = "e2e #{System.os_time(:second)}"
    common = %{"change_reason" => run_id, "confirmed_changes" => true}

    site = client |> Sites.list_sites!(study) |> Map.fetch!(:entries) |> hd()
    participant = participant(client, study, site)

    fields = client |> Fields.stream_fields(study, include: "optiongroup") |> Enum.to_list()
    forms = client |> Forms.stream_forms(study) |> MapSet.new(& &1.id)
    study_fields = Enum.filter(fields, &MapSet.member?(forms, &1.parent_id))

    study_result =
      DataPoints.upsert_study_data_points!(client, study, participant.participant_id, %{
        "common" => common,
        "data" => values(study_fields)
      })

    repeating_data = client |> RepeatingData.list_repeating_data!(study) |> Map.fetch!(:entries) |> hd()

    instance =
      RepeatingData.create_repeating_data_instance!(client, study, participant.participant_id, %{
        "repeating_data_id" => repeating_data.id,
        "repeating_data_name" => run_id
      })

    repeating_forms =
      client
      |> RepeatingData.stream_repeating_data_forms(study, repeating_data.id)
      |> MapSet.new(& &1.id)

    repeating_fields = Enum.filter(fields, &MapSet.member?(repeating_forms, &1.parent_id))

    repeating_result =
      DataPoints.upsert_repeating_data_instance_data_points!(client, study, participant.participant_id, instance.id, %{
        "common" => common,
        "data" => values(repeating_fields)
      })

    survey = seed_survey(client, study, participant.participant_id, fields, common)

    Map.merge(survey, %{
      "run_id" => run_id,
      "participant_id" => participant.participant_id,
      "site_id" => site.id,
      "repeating_data_id" => repeating_data.id,
      "repeating_data_instance_id" => instance.id,
      "study_field_id" => first_saved(study_result),
      "repeating_field_id" => first_saved(repeating_result),
      "study_values" => length(study_result.saved),
      "repeating_data_values" => length(repeating_result.saved)
    })
  end

  # A study that has never been live allows only ten participants; once it
  # has them, the seed reuses the latest one rather than failing.
  defp participant(client, study, site) do
    case Participants.create_participant(client, study, %{"site_id" => site.id}) do
      {:ok, participant} ->
        participant

      {:error, error} ->
        Mix.shell().info("Reusing the latest participant, as creating one failed: #{error.message}")
        client |> Participants.stream_participants(study) |> Enum.max_by(& &1.created_on, DateTime)
    end
  end

  # A survey package instance for the participant, which sends an invitation
  # to an example.org address, and a value for one field of its first survey.
  defp seed_survey(client, study, participant_id, fields, common) do
    package = client |> Surveys.list_survey_packages!(study) |> Map.fetch!(:entries) |> hd()

    instance =
      Surveys.create_survey_package_instance!(client, study, %{
        "participant_id" => participant_id,
        "survey_package_id" => package.id,
        "email_address" => "e2e@example.org",
        "ccr_patient_id" => ""
      })

    # Creating one doesn't return its survey instances; reading it does.
    instance = Surveys.get_survey_package_instance!(client, study, instance.id)
    survey_instance = hd(instance.survey_instances)
    survey_id = get_in(survey_instance, ["_embedded", "survey", "id"])
    survey_forms = client |> Surveys.stream_survey_forms(study, survey_id) |> MapSet.new(& &1.id)

    field =
      Enum.find(fields, fn field -> MapSet.member?(survey_forms, field.parent_id) and value(field) != nil end)

    DataPoints.create_survey_data_point!(client, study, participant_id, survey_instance["id"], field.id, %{
      "field_value" => value(field),
      "change_reason" => common["change_reason"],
      "confirmed_changes" => true
    })

    %{
      "survey_package_instance_id" => instance.id,
      "survey_instance_id" => survey_instance["id"],
      "survey_field_id" => field.id
    }
  end

  defp first_saved(%{saved: [first | _rest]}), do: first.field_id
  defp first_saved(_result), do: nil

  # A valid value for every field that holds one, and a user-missing value
  # for the first numeric field.
  defp values(fields) do
    {missing, valued} =
      case Enum.split_with(fields, &(&1.field_type == "numeric")) do
        {[first | numeric], other} -> {[first], numeric ++ other}
        {[], other} -> {[], other}
      end

    Enum.map(missing, &%{"field_id" => &1.id, "field_value" => "##USER_MISSING_95##"}) ++
      for field <- valued, value = value(field), do: %{"field_id" => field.id, "field_value" => value}
  end

  defp value(%{field_type: "numeric"} = field), do: field |> number_in_range() |> to_string()
  defp value(%{field_type: "slider"} = field), do: field |> number_in_range() |> to_string()
  defp value(%{field_type: "year"}), do: "2015"
  defp value(%{field_type: "date"}), do: "07-10-2026"
  defp value(%{field_type: "time"}), do: "12:30"
  defp value(%{field_type: "datetime"}), do: "07-10-2026;12:30"
  defp value(%{field_type: type}) when type in ["string", "textarea"], do: "e2e text; with a semicolon"
  defp value(%{field_type: type} = field) when type in ["radio", "dropdown"], do: field |> options() |> List.first()
  defp value(%{field_type: "checkbox"} = field), do: field |> options() |> Enum.take(2) |> join_options()
  defp value(_layout_or_unsupported), do: nil

  defp number_in_range(%{field_min: min, field_max: max}) do
    cond do
      is_number(min) -> trunc(min) + 1
      is_number(max) -> trunc(max) - 1
      true -> 7
    end
  end

  defp options(%{option_group: %{options: options}}) when is_list(options), do: Enum.map(options, & &1.value)
  defp options(_field), do: []

  defp join_options([]), do: nil
  defp join_options(values), do: Enum.join(values, ";")
end
