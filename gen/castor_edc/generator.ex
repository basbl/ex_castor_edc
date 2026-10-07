defmodule CastorEDC.Generator do
  @moduledoc """
  Generates the client from the corrected API spec.

  `priv/openapi/castor_edc.json` is the source of truth for every operation
  the client has. `mix castor_edc.gen.client` reads it and writes one module
  per operation group (`CastorEDC.Participants` and the rest) and one struct
  per response schema (under `CastorEDC.Model`) into `lib/castor_edc/`.

  The generated functions only describe their operation; how a request is
  made is up to the handwritten `CastorEDC.Client`, so changing that is an
  edit to one module rather than a regeneration.

  The pieces:

    * `CastorEDC.Generator.Spec` reads the spec into structs
    * `CastorEDC.Generator.Naming` turns its names into Elixir names
    * `CastorEDC.Generator.Renderer` renders the structs into source

  Generated files start with `CastorEDC.Generator.Renderer.banner/0`. That's
  how `write!/2` finds the generated files the spec no longer calls for and
  deletes them, while leaving handwritten modules alone.

  This module and its Mix task are development tooling: they live in
  `gen/`, which is compiled in `:dev` and `:test` only and isn't part of the
  published package.
  """

  alias CastorEDC.Generator.Naming
  alias CastorEDC.Generator.Renderer
  alias CastorEDC.Generator.Spec

  @doc """
  Reads and parses the spec at `path`.
  """
  @spec load!(Path.t()) :: Spec.t()
  def load!(path), do: path |> File.read!() |> JSON.decode!() |> Spec.parse()

  @doc """
  Renders every file the spec calls for, as `{path, source}` pairs, with
  paths relative to the project.
  """
  @spec files(Spec.t()) :: [{Path.t(), String.t()}]
  def files(%Spec{} = spec) do
    modules = for group <- spec.groups, do: {Naming.path(group.module), Renderer.module(group)}
    models = for model <- spec.models, do: {Naming.path(model.module), Renderer.model(model)}

    modules ++ models
  end

  @doc """
  Compares `files` with what's in `root`, returning the paths that would be
  created, changed, deleted and left alone, each sorted.
  """
  @spec diff([{Path.t(), String.t()}], Path.t()) :: %{
          created: [Path.t()],
          changed: [Path.t()],
          deleted: [Path.t()],
          unchanged: [Path.t()]
        }
  def diff(files, root) do
    written =
      Enum.group_by(files, fn {path, source} ->
        case File.read(Path.join(root, path)) do
          {:ok, ^source} -> :unchanged
          {:ok, _other} -> :changed
          {:error, _reason} -> :created
        end
      end)

    wanted = MapSet.new(files, &elem(&1, 0))
    deleted = root |> generated_files() |> Enum.reject(&MapSet.member?(wanted, &1))

    %{
      created: paths(written[:created]),
      changed: paths(written[:changed]),
      unchanged: paths(written[:unchanged]),
      deleted: Enum.sort(deleted)
    }
  end

  @doc """
  Writes `files` into `root` and deletes generated files no longer called
  for. Returns the same report as `diff/2`.
  """
  @spec write!([{Path.t(), String.t()}], Path.t()) :: map()
  def write!(files, root) do
    report = diff(files, root)

    for {path, source} <- files, path in report.created or path in report.changed do
      target = Path.join(root, path)
      File.mkdir_p!(Path.dirname(target))
      File.write!(target, source)
    end

    for path <- report.deleted, do: File.rm!(Path.join(root, path))

    report
  end

  defp paths(nil), do: []
  defp paths(files), do: files |> Enum.map(&elem(&1, 0)) |> Enum.sort()

  # Files under lib/castor_edc that start with the banner.
  defp generated_files(root) do
    banner = Renderer.banner()

    root
    |> Path.join("lib/castor_edc/**/*.ex")
    |> Path.wildcard()
    |> Enum.filter(fn file -> file |> File.read!() |> String.starts_with?(banner) end)
    |> Enum.map(&Path.relative_to(&1, root))
  end
end
