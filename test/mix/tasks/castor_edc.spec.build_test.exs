defmodule Mix.Tasks.CastorEdc.Spec.BuildTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.CastorEdc.Spec.Build

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    upstream = Path.join(tmp_dir, "upstream.json")
    overlay = Path.join(tmp_dir, "overlay.yaml")
    output = Path.join(tmp_dir, "castor_edc.json")

    File.write!(upstream, ~s({
      "swagger": "2.0",
      "info": {"title": "API", "version": "1"},
      "host": "data.castoredc.com",
      "basePath": "/api/",
      "paths": {
        "/": [],
        "/study": {"get": {"summary": "List studies", "responses": {"200": {"description": "OK"}}}}
      }
    }))

    File.write!(overlay, """
    overlay: 1.0.0
    info: {title: Test, version: 1.0.0}
    actions:
      - target: $.paths['/']
        remove: true
      - target: $.paths['/study'].get
        update: {operationId: list_studies}
    """)

    args = ["--upstream", upstream, "--overlay", overlay, "--output", output]

    %{args: args, output: output}
  end

  test "applies the overlay, converts the result and writes it", %{args: args, output: output} do
    Build.run(args)

    spec = output |> File.read!() |> JSON.decode!()

    assert spec["openapi"] == "3.1.0"
    assert Map.keys(spec["paths"]) == ["/study"]
    assert spec["paths"]["/study"]["get"]["operationId"] == "list_studies"
    assert_received {:mix_shell, :info, ["Wrote " <> _path]}
  end

  test "--check passes when the output is current and fails otherwise", %{args: args, output: output} do
    assert_raise Mix.Error, ~r/out of date/, fn -> Build.run(["--check" | args]) end

    Build.run(args)
    assert Build.run(["--check" | args]) == :ok

    File.write!(output, "{}\n")
    assert_raise Mix.Error, ~r/out of date/, fn -> Build.run(["--check" | args]) end
  end
end
