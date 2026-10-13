defmodule CastorEDC.Generator.RendererTest do
  use CastorEDC.Case, async: true

  alias CastorEDC.Generator.Renderer
  alias CastorEDC.Generator.Spec
  # The sample's models are compiled under a namespace of their own, so they
  # can't replace the real models.
  @sample CastorEDC.GeneratorSample.Model
  @site Module.concat(@sample, Site)
  @tag_model Module.concat(@sample, Tag)
  @country Module.concat(@sample, Country)
  @sites CastorEDC.GeneratorSample.Sites

  defp sample_namespace(source) do
    source
    |> String.replace(~r/CastorEDC\.Model\.(?=[A-Z])/, inspect(@sample) <> ".")
    |> String.replace(~r/CastorEDC\.(Sites|Exports|DataPoints|RepeatingData)\b/, "CastorEDC.GeneratorSample.\\1")
  end

  setup_all do
    spec = Spec.parse(CastorEDC.GeneratorSample.document())
    sources = Map.new(spec.models, &{&1.name, Renderer.model(&1)})

    modules = Map.new(spec.groups, &{&1.name, Renderer.module(&1)})

    for {_name, source} <- Map.merge(sources, modules) do
      source |> sample_namespace() |> Code.compile_string()
    end

    # The sample models only exist once compiled here, so tests get the
    # module from the context rather than naming it.
    %{sources: sources, modules: modules, site: @site, sites: @sites}
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

  test "allows the struct field count of an API object with 31 fields or more" do
    fields = for n <- 1..31, do: %Spec.Field{name: "field_#{n}", wires: ["field_#{n}"], type: {:string, nil}}
    small = %Spec.Model{name: "Small", module: CastorEDC.Model.Small, fields: Enum.take(fields, 30)}
    large = %{small | name: "Large", module: CastorEDC.Model.Large, fields: fields}

    refute Renderer.model(small) =~ "credo:disable"
    assert Renderer.model(large) =~ "credo:disable-for-this-file Credo.Check.Warning.StructFieldAmount"
  end

  test "leaves the spec's HAL wording out and turns its HTML into Markdown" do
    assert Renderer.upstream_text("Gets sites.\nReturns HalJson objects (with _links).\nCan be paged.") == "Gets sites."

    assert Renderer.upstream_text(
             "Returns an array of objects. Paged.\nAlways requires a study_id to be given. Listed."
           ) ==
             "Listed."

    assert Renderer.upstream_text("<b>Sites</b> to create: <br/> <i>name</i> of the site") ==
             "**Sites** to create:\n _name_ of the site"
  end

  test "keeps descriptions inside the heredoc" do
    assert Renderer.doc("first\nsecond\n\nfourth  ") == "first\n  second\n\n  fourth"
    assert Renderer.doc(~s|has """ inside|) == "has ''' inside"
  end

  describe "an operation module" do
    test "starts with the banner, is formatted and lists its operations", %{modules: modules} do
      source = modules["Sites"]

      assert String.starts_with?(source, Renderer.banner())
      assert source == Renderer.format(source)
      assert source =~ "* `get_site/4` - Retrieve a single Site"
      assert source =~ "Sends `GET /api/study/{study_id}/site/{site_id}`."
      assert source =~ "* `:field_ids` (list of string, sent comma-separated)"
      assert source =~ "* `:page_size` (integer, at most `1000`; a larger one is lowered to it)"
      assert source =~ "Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Site.t/0` records."
    end

    test "fills list items from path parameters, and says so", %{modules: modules} do
      source = modules["DataPoints"]

      assert source =~ ~s(fill_items: %{"data" => %{"instance_id" => "repeating_data_instance_id"}})
      assert source =~ "Each item of `data` that has no `instance_id` gets `repeating_data_instance_id`"
    end

    test "documents streaming a download to disk", %{modules: modules} do
      source = modules["Exports"]

      assert source =~ "{:ok, binary() | Collectable.t()}"
      assert source =~ "`into: File.stream!(path)` streams it to\n  disk"
    end

    test "sends the operation and decodes the response", %{sites: sites, site: site} do
      client = client(json(%{"id" => "S2", "siteName" => "Castor"}))

      assert {:ok, %{__struct__: ^site, id: "S2", site_name: "Castor"}} = sites.get_site(client, "ST", "S2")
      assert assert_requested().url.path == "/api/study/ST/site/S2"
    end

    test "sends options under their wire names, and the rest to Req", %{sites: sites} do
      client = client(json(%{"_embedded" => %{"sites" => []}, "page" => 1, "page_count" => 1}))

      sites.list_sites(client, "ST", page: 2, field_ids: ["a", "b"], site_ids: "x", receive_timeout: 5000)

      request = assert_requested()
      assert URI.decode_query(request.url.query) == %{"page" => "2", "field_ids" => "a,b", "siteId[]" => "x"}
      assert request.options.receive_timeout == 5000
    end

    test "sends a body", %{sites: sites} do
      client = client(json(%{"id" => "S3"}, status: 201))

      assert {:ok, %{id: "S3"}} = sites.create_site(client, "ST", %{"name" => "Castor"})

      request = assert_requested()
      assert request.method == :post
      assert Req.Request.get_header(request, "accept") == ["application/json"]
      assert request.body |> IO.iodata_to_binary() |> JSON.decode!() == %{"name" => "Castor"}
    end

    test "has a ! variant", %{sites: sites} do
      assert %{id: "S2"} = sites.get_site!(client(json(%{"id" => "S2"})), "ST", "S2")
      assert_raise CastorEDC.Error, fn -> sites.get_site!(client(json(%{}, status: 404)), "ST", "S2") end
    end

    test "streams a paged collection", %{sites: sites} do
      responder = fn request ->
        page = request.url.query |> URI.decode_query() |> Map.fetch!("page") |> String.to_integer()
        json(%{"_embedded" => %{"sites" => [%{"id" => "S#{page}"}]}, "page" => page, "page_count" => 2})
      end

      assert responder |> client() |> sites.stream_sites("ST") |> Enum.map(& &1.id) == ["S1", "S2"]
      assert URI.decode_query(assert_requested().url.query) == %{"page" => "1", "page_size" => "1000"}
    end
  end
end
