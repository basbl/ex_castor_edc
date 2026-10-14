defmodule Mix.Tasks.CastorEdc.Gen.ClientTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Renderer
  alias Mix.Tasks.CastorEdc.Gen.Client

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    spec = Path.join(tmp_dir, "castor_edc.json")
    File.write!(spec, JSON.encode!(CastorEDC.GeneratorSample.document()))

    %{args: ["--spec", spec, "--root", tmp_dir], root: tmp_dir}
  end

  test "writes a module per group and a struct per schema", %{args: args, root: root} do
    Client.run(args)

    assert File.read!(Path.join(root, "lib/castor_edc/sites.ex")) =~ "defmodule CastorEDC.Sites do"
    assert File.read!(Path.join(root, "lib/castor_edc/model/site.ex")) =~ "defmodule CastorEDC.Model.Site do"
    assert_received {:mix_shell, :info, ["Generated 7 files: 7 created, 0 changed, 0 deleted, 0 unchanged"]}
  end

  test "deletes generated files the spec no longer calls for, and only those", %{args: args, root: root} do
    stale = Path.join(root, "lib/castor_edc/model/gone.ex")
    handwritten = Path.join(root, "lib/castor_edc/client.ex")
    File.mkdir_p!(Path.dirname(stale))
    File.write!(stale, Renderer.banner() <> "\n\ndefmodule CastorEDC.Model.Gone do\nend\n")
    File.write!(handwritten, "defmodule CastorEDC.Client do\nend\n")

    Client.run(args)

    refute File.exists?(stale)
    assert File.exists?(handwritten)
    assert_received {:mix_shell, :info, ["Generated 7 files: 7 created, 0 changed, 1 deleted, 0 unchanged"]}
  end

  test "--check fails until the generated files are current", %{args: args, root: root} do
    assert_raise Mix.Error, ~r/out of date/, fn -> Client.run(["--check" | args]) end

    Client.run(args)
    assert Client.run(["--check" | args]) == :ok

    File.write!(Path.join(root, "lib/castor_edc/sites.ex"), "edited by hand")
    assert_raise Mix.Error, ~r/lib\/castor_edc\/sites.ex/, fn -> Client.run(["--check" | args]) end
  end
end
