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

  # The docs can't read the version from mix.exs, so this keeps the
  # requirement they tell users to install with in step with it. A
  # pre-release has to be named, as "~> 1.0" doesn't match "1.0.0-rc.1".
  test "the docs install the version mix.exs gives" do
    version = Version.parse!(Mix.Project.config()[:version])
    expected = if version.pre == [], do: "~> #{version.major}.#{version.minor}", else: "~> #{version}"

    assert Version.match?(version, expected, allow_pre: true)

    for doc <- ["README.md", "guides/migrating-to-1.0.md", "notebook/getting_started.livemd"] do
      requirements = Regex.scan(~r/\{:ex_castor_edc, "([^"]+)"\}/, File.read!(doc), capture: :all_but_first)

      assert requirements != [], "#{doc} doesn't say how to install the library"

      for [requirement] <- requirements do
        assert requirement == expected, "#{doc} installs #{inspect(requirement)} instead of #{inspect(expected)}"
      end
    end
  end
end
