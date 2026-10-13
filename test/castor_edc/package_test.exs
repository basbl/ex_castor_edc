defmodule CastorEDC.PackageTest do
  use ExUnit.Case, async: true

  # A file a module reads when it compiles has to ship in the package, or the
  # package doesn't compile for anyone who installs it.
  test "packages every file the library reads at compile time" do
    files = Mix.Project.config()[:package][:files]
    root = File.cwd!()

    resources =
      for {:ok, modules} <- [:application.get_key(:ex_castor_edc, :modules)],
          module <- modules,
          # The generator in gen/ is development tooling, not packaged.
          module.module_info(:compile)[:source] |> to_string() |> String.starts_with?(Path.join(root, "lib")),
          {:external_resource, paths} <- module.__info__(:attributes),
          path <- paths,
          do: Path.relative_to(path, root)

    assert resources != []

    for resource <- resources do
      assert Enum.any?(files, &(resource == &1 or String.starts_with?(resource, &1 <> "/"))),
             "#{resource} is read at compile time but isn't in the package's files"
    end
  end
end
