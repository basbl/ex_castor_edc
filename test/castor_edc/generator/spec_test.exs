defmodule CastorEDC.Generator.SpecTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Spec
  alias CastorEDC.Model.Site
  alias CastorEDC.Model.Tag

  doctest CastorEDC.Generator.Naming

  @document CastorEDC.GeneratorSample.document()

  setup_all do
    spec = Spec.parse(@document)
    operations = Map.new(Enum.flat_map(spec.groups, & &1.operations), &{&1.name, &1})
    models = Map.new(spec.models, &{&1.name, &1})

    %{spec: spec, operations: operations, models: models}
  end

  test "groups operations by x-castor-module, sorted", %{spec: spec} do
    assert Enum.map(spec.groups, &{&1.name, &1.module}) == [
             {"DataPoints", CastorEDC.DataPoints},
             {"Exports", CastorEDC.Exports},
             {"RepeatingData", CastorEDC.RepeatingData},
             {"Sites", CastorEDC.Sites}
           ]

    assert spec.groups |> List.last() |> Map.fetch!(:operations) |> Enum.map(& &1.name) ==
             ["create_site", "get_site", "list_sites"]
  end

  test "prefixes paths with the server's base path", %{spec: spec, operations: operations} do
    assert spec.base_path == "/api"
    assert operations["get_site"].path == "/api/study/{study_id}/site/{site_id}"
    assert operations["get_site"].method == :get
  end

  test "orders path parameters as the path does, under their Elixir names", %{operations: operations} do
    assert Enum.map(operations["get_site"].path_params, &{&1.name, &1.wire}) ==
             [{"study_id", "study_id"}, {"site_id", "site_id"}]

    assert Enum.map(operations["download_export"].path_params, &{&1.name, &1.wire}) ==
             [{"study_id", "study_id"}, {"export_id", "id"}]
  end

  test "reads query parameters, lists and paging", %{operations: operations} do
    list = operations["list_sites"]

    assert Enum.map(list.query_params, &{&1.name, &1.wire, &1.encoding}) == [
             {"page", "page", :plain},
             {"page_size", "page_size", :plain},
             {"field_ids", "field_ids", :csv},
             {"site_ids", "siteId[]", :plain}
           ]

    assert hd(list.query_params).default == 1
    assert list.paged
    assert list.max_page_size == 1000
    refute operations["get_site"].paged
  end

  test "decodes into the model of the response, or of a collection's records", %{operations: operations} do
    assert operations["get_site"].decode == Site
    assert operations["create_site"].decode == Site
    assert operations["list_sites"].decode == Site
    assert operations["list_sites"].items == "_embedded.sites"
    assert operations["download_export"].decode == nil
  end

  test "asks for what the response is", %{operations: operations} do
    assert operations["get_site"].accept == nil
    assert operations["create_site"].accept == "application/json"
    assert operations["download_export"].accept == "*/*"
  end

  test "reads the request body", %{operations: operations} do
    body = operations["create_site"].body

    assert body.required
    assert Enum.map(body.fields, &{&1.name, &1.required}) == [{"name", true}, {"abbreviation", false}]
    assert operations["get_site"].body == nil
  end

  test "keeps the flags of the corrections", %{operations: operations} do
    assert operations["list_repeating_data_instances"].not_found_is_empty == "There are no repeating data instances."
    assert operations["upsert_study_data_points"].partial_success

    assert operations["upsert_repeating_data_instance_data_points"].fill_items == %{
             "data" => %{"instance_id" => "repeating_data_instance_id"}
           }

    assert operations["upsert_study_data_points"].fill_items == %{}
    refute operations["list_sites"].not_found_is_empty
  end

  test "links to the API reference", %{operations: operations} do
    assert operations["get_site"].doc_url == "https://data.castoredc.com/api#/site/get_study__study_id__site__site_id_"
  end

  test "makes models of the schemas successful responses reach, but not links or errors", %{models: models} do
    assert models |> Map.keys() |> Enum.sort() == ["Country", "Site", "Tag"]
    assert models["Site"].module == Site
    assert models["Site"].description == "A site."
  end

  test "reads a model's fields", %{models: models} do
    fields = Map.new(models["Site"].fields, &{&1.name, &1})

    assert fields |> Map.keys() |> Enum.sort() ==
             ["country", "country_id", "created_on", "id", "labels", "site_name", "tags", "value"]

    assert hd(models["Site"].fields).name == "id"
    assert fields["id"].required
    assert fields["id"].description == "The site's ID"
    assert fields["site_name"].wires == ["siteName"]
    assert fields["value"].wires == ["field_value", "value"]
    assert fields["created_on"].decode == {:cast, :datetime}
    assert fields["tags"].decode == {:list, Tag}
    assert fields["labels"].decode == {:list, Tag}
    assert fields["labels"].type == {:list, {:model, Tag}}
    assert fields["country"].decode == {:one, CastorEDC.Model.Country}
    assert fields["country"].wires == ["_embedded.country"]
    assert fields["country_id"].type == {:integer, nil}
  end

  test "refuses operations without a name or module" do
    document = put_in(@document, ["paths", "/study/{study_id}/site/{site_id}", "get", "operationId"], nil)
    assert_raise ArgumentError, ~r/no operationId/, fn -> Spec.parse(document) end
  end

  test "refuses to fill items from a parameter the path doesn't have" do
    document =
      put_in(
        @document,
        ["paths", "/study/{study_id}/site/{site_id}", "get", "x-castor-fill-items"],
        %{"data" => %{"instance_id" => "instance_id"}}
      )

    assert_raise ArgumentError, ~r/get_site fills items from \{instance_id\}, which isn't in its path/, fn ->
      Spec.parse(document)
    end
  end
end
