defmodule Mix.Tasks.CastorEdc.Spec.FetchTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.CastorEdc.Spec.Fetch

  @moduletag :tmp_dir

  test "writes the spec with sorted keys", %{tmp_dir: tmp_dir} do
    source = Path.join(tmp_dir, "swagger.json")
    output = Path.join(tmp_dir, "openapi/upstream.json")

    File.write!(source, ~s({"swagger": "2.0", "info": {"version": "1.0", "title": "API"}, "paths": {}}))

    Fetch.run(["--url", "file://" <> source, "--output", output])

    assert File.read!(output) == """
           {
             "info": {
               "title": "API",
               "version": "1.0"
             },
             "paths": {},
             "swagger": "2.0"
           }
           """

    assert_received {:mix_shell, :info, ["Wrote " <> _message]}
  end

  test "rejects unknown options" do
    assert_raise OptionParser.ParseError, fn -> Fetch.run(["--unknown", "x"]) end
  end
end
