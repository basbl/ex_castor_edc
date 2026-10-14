defmodule Mix.Tasks.CastorEdc.Spec.Build do
  @shortdoc "Builds priv/openapi/castor_edc.json from the upstream spec and our corrections"

  @moduledoc """
  Builds `priv/openapi/castor_edc.json`, the API spec the client is
  generated from.

      $ mix castor_edc.spec.build
      $ mix castor_edc.spec.build --check

  It reads the spec as published (`priv/openapi/upstream.json`, from
  `mix castor_edc.spec.fetch`), applies our corrections
  (`priv/openapi/overlay.yaml`, see `CastorEDC.Generator.Overlay`), drops
  path items the corrections left without operations, converts the result
  to OpenAPI 3.1 (see `CastorEDC.Generator.Swagger2`), and writes it with
  sorted keys and indentation.

  ## Options

    * `--check` - writes nothing, and fails if `castor_edc.json` isn't what
      the upstream spec and the overlay produce. `mix quality` runs this, so
      a changed overlay can't be committed without the spec it builds.
  """

  use Mix.Task

  alias CastorEDC.Generator.JSON
  alias CastorEDC.Generator.Overlay
  alias CastorEDC.Generator.Swagger2

  @upstream "priv/openapi/upstream.json"
  @overlay "priv/openapi/overlay.yaml"
  @output "priv/openapi/castor_edc.json"

  @impl Mix.Task
  def run(args) do
    {opts, _args} =
      OptionParser.parse!(args, strict: [check: :boolean, upstream: :string, overlay: :string, output: :string])

    upstream = Keyword.get(opts, :upstream, @upstream)
    overlay = Keyword.get(opts, :overlay, @overlay)
    output = Keyword.get(opts, :output, @output)

    {:ok, _apps} = Application.ensure_all_started(:yaml_elixir)

    spec =
      upstream
      |> File.read!()
      |> Elixir.JSON.decode!()
      |> Overlay.apply!(YamlElixir.read_from_file!(overlay))
      |> drop_empty_path_items()
      |> Swagger2.convert!()
      |> JSON.encode!()

    if opts[:check] do
      check!(output, spec)
    else
      File.write!(output, spec)
      Mix.shell().info("Wrote #{output}")
    end
  end

  @operation_methods ~w(get put post delete options head patch)

  # Removing every operation of a path leaves an empty path item behind.
  # Anything that isn't an object is left for the conversion to reject.
  defp drop_empty_path_items(spec) do
    Map.update!(spec, "paths", fn paths ->
      Map.reject(paths, fn {_path, item} ->
        is_map(item) and not Enum.any?(@operation_methods, &Map.has_key?(item, &1))
      end)
    end)
  end

  defp check!(output, spec) do
    case File.read(output) do
      {:ok, ^spec} ->
        :ok

      _missing_or_different ->
        Mix.raise("#{output} is out of date with the upstream spec and the overlay; run `mix castor_edc.spec.build`")
    end
  end
end
