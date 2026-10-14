defmodule CastorEDC.Generator.Naming do
  @moduledoc """
  Turns names from the API spec into Elixir names.

  The spec mixes snake_case, camelCase and names with brackets
  (`participantId[]`); Elixir names are snake_case for functions, arguments
  and fields, and CamelCase for modules. Names the corrections set
  explicitly (`operationId`, `x-castor-module`, `x-castor-name`,
  `x-castor-rename`) are used as they are.
  """

  @doc """
  A snake_case name for a parameter or field.

      iex> CastorEDC.Generator.Naming.snake("fieldDependency_id")
      "field_dependency_id"
      iex> CastorEDC.Generator.Naming.snake("participantId[]")
      "participant_id"
      iex> CastorEDC.Generator.Naming.snake("finished_on[gt]")
      "finished_on_gt"
  """
  @spec snake(String.t()) :: String.t()
  def snake(name) do
    name
    |> String.replace(~r/\[\]$/, "")
    |> String.replace(~r/[^A-Za-z0-9_]+/, "_")
    |> Macro.underscore()
    |> String.replace(~r/_+/, "_")
    |> String.trim("_")
  end

  @doc """
  The module of an operation group, from its `x-castor-module`.

      iex> CastorEDC.Generator.Naming.group_module("Participants")
      CastorEDC.Participants
  """
  @spec group_module(String.t()) :: module()
  def group_module(name), do: Module.concat(CastorEDC, name)

  @doc """
  The struct module of a schema.

      iex> CastorEDC.Generator.Naming.model_module("SurveyPackageInstance")
      CastorEDC.Model.SurveyPackageInstance
      iex> CastorEDC.Generator.Naming.model_module("newInstitute")
      CastorEDC.Model.NewInstitute
      iex> CastorEDC.Generator.Naming.model_module("Not_Acceptable")
      CastorEDC.Model.NotAcceptable
  """
  @spec model_module(String.t()) :: module()
  def model_module(schema_name) do
    name =
      schema_name
      |> String.split(~r/[^A-Za-z0-9]+/, trim: true)
      |> Enum.map_join(&upcase_first/1)

    Module.concat(CastorEDC.Model, name)
  end

  @doc """
  The source file of a generated module, relative to the project.

      iex> CastorEDC.Generator.Naming.path(CastorEDC.Model.SurveyPackageInstance)
      "lib/castor_edc/model/survey_package_instance.ex"
  """
  @spec path(module()) :: Path.t()
  def path(module) do
    ["Elixir", "CastorEDC" | rest] = module |> Atom.to_string() |> String.split(".")
    Path.join(["lib", "castor_edc" | Enum.map(rest, &Macro.underscore/1)]) <> ".ex"
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
end
