defmodule CastorEDC.Generator.RendererTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Renderer
  alias CastorEDC.Generator.Spec
  # The sample's models are compiled under a namespace of their own, so they
  # can't replace the real models.
  @sample CastorEDC.GeneratorSample.Model
  @site Module.concat(@sample, Site)
  @tag_model Module.concat(@sample, Tag)
  @country Module.concat(@sample, Country)

  setup_all do
    spec = Spec.parse(CastorEDC.GeneratorSample.document())
    sources = Map.new(spec.models, &{&1.name, Renderer.model(&1)})

    for {_name, source} <- sources do
      source |> String.replace(~r/CastorEDC\.Model\.(?=[A-Z])/, inspect(@sample) <> ".") |> Code.compile_string()
    end

    # The sample models only exist once compiled here, so tests get the
    # module from the context rather than naming it.
    %{sources: sources, site: @site}
  end

  describe "a model" do
    test "starts with the banner and is formatted", %{sources: sources} do
      source = sources["Site"]

      assert String.starts_with?(source, Renderer.banner())
      assert source == Renderer.format(source)
    end

    test "documents its fields", %{sources: sources} do
      source = sources["Site"]

      assert source =~ "A site."
      assert source =~ "* `:id` (string, always present) - The site's ID"
      assert source =~ "* `:tags` (list of `t:CastorEDC.Model.Tag.t/0`)"
      assert source =~ "* `:created_on` (`DateTime`)"
      assert source =~ "* `:extra` - every key the API sent"
    end

    test "decodes a response, keeping keys it doesn't name in extra", %{site: site} do
      site =
        site.new(%{
          "id" => "S1",
          "siteName" => "Castor",
          "field_value" => "42",
          "created_on" => %{"date" => "2026-10-07 21:08:46.000000", "timezone" => "Europe/Amsterdam"},
          "tags" => [%{"name" => "a"}],
          "_links" => %{"self" => %{}},
          "_embedded" => %{"country" => %{"name" => "Netherlands"}, "unknown" => 1},
          "new_field" => true
        })

      assert %{__struct__: @site, id: "S1", site_name: "Castor", value: "42"} = site
      assert [%{__struct__: @tag_model, name: "a"}] = site.tags
      assert %{__struct__: @country, name: "Netherlands"} = site.country

      assert %DateTime{time_zone: "Europe/Amsterdam"} = site.created_on
      assert site.extra == %{"new_field" => true, "unknown" => 1}
    end

    test "reads a renamed field under either name", %{site: site} do
      assert site.new(%{"value" => "1"}).value == "1"
      assert site.new(%{"field_value" => "2"}).value == "2"
    end

    test "finds objects the API embeds although the spec doesn't say so", %{site: site} do
      site = site.new(%{"_embedded" => %{"tags" => [%{"name" => "embedded"}]}})

      assert [%{__struct__: @tag_model, name: "embedded"}] = site.tags
      assert site.extra == %{}
    end

    test "leaves missing fields nil", %{site: site} do
      assert %{__struct__: @site, id: nil, tags: nil, country: nil, extra: %{}} = site.new(%{})
    end
  end

  test "keeps descriptions inside the heredoc" do
    assert Renderer.doc("first\nsecond\n\nfourth  ") == "first\n  second\n\n  fourth"
    assert Renderer.doc(~s|has """ inside|) == "has ''' inside"
  end
end
