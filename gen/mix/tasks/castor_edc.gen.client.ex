defmodule Mix.Tasks.CastorEdc.Gen.Client do
  @shortdoc "Generates the client's modules and structs from the API spec"

  @moduledoc """
  Generates the client from `priv/openapi/castor_edc.json`.

      $ mix castor_edc.gen.client
      $ mix castor_edc.gen.client --check

  Writes one module per operation group and one struct per response schema
  into `lib/castor_edc/`, and deletes generated files the spec no longer
  calls for. See `CastorEDC.Generator`.

  ## Options

    * `--check` - writes nothing, and fails if the generated files aren't
      what the spec produces. `mix quality` runs this.
    * `--spec` - the spec to read, `priv/openapi/castor_edc.json` by default.
    * `--root` - the project to write into, the current directory by default.
  """

  use Mix.Task

  alias CastorEDC.Generator

  @impl Mix.Task
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: [check: :boolean, spec: :string, root: :string])
    root = Keyword.get(opts, :root, File.cwd!())
    files = opts |> Keyword.get(:spec, "priv/openapi/castor_edc.json") |> Generator.load!() |> Generator.files()

    if opts[:check] do
      check!(files, root)
    else
      report = Generator.write!(files, root)

      Mix.shell().info(
        "Generated #{length(files)} files: #{length(report.created)} created, " <>
          "#{length(report.changed)} changed, #{length(report.deleted)} deleted, " <>
          "#{length(report.unchanged)} unchanged"
      )
    end
  end

  defp check!(files, root) do
    case Generator.diff(files, root) do
      %{created: [], changed: [], deleted: []} ->
        :ok

      report ->
        stale = report.created ++ report.changed ++ report.deleted

        Mix.raise("""
        the generated client is out of date with the spec; run `mix castor_edc.gen.client`.
        Out of date: #{Enum.join(stale, ", ")}
        """)
    end
  end
end
