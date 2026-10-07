defmodule CastorEDC.Generator.SpecTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Spec
  alias CastorEDC.Model.Site

  doctest CastorEDC.Generator.Naming

  @document %{
    "openapi" => "3.1.0",
    "servers" => [%{"url" => "https://data.castoredc.com/api"}],
    "paths" => %{
      "/study/{study_id}/site/{site_id}" => %{
        "get" => %{
          "operationId" => "get_site",
          "x-castor-module" => "Sites",
          "summary" => "Retrieve a single Site",
          "tags" => ["site"],
          "parameters" => [
            %{"name" => "site_id", "in" => "path", "required" => true, "schema" => %{"type" => "string"}},
            %{"name" => "study_id", "in" => "path", "required" => true, "schema" => %{"type" => "string"}}
          ],
          "responses" => %{
            "200" => %{"content" => %{"application/hal+json" => %{"schema" => %{"$ref" => "#/components/schemas/Site"}}}},
            "404" => %{"content" => %{"application/json" => %{"schema" => %{"$ref" => "#/components/schemas/Error"}}}}
          }
        }
      },
      "/study/{study_id}/site" => %{
        "get" => %{
          "operationId" => "list_sites",
          "x-castor-module" => "Sites",
          "x-castor-items" => "_embedded.sites",
          "x-castor-max-page-size" => 1000,
          "parameters" => [
            %{"name" => "study_id", "in" => "path", "required" => true, "schema" => %{"type" => "string"}},
            %{"name" => "page", "in" => "query", "schema" => %{"type" => "integer", "default" => 1}},
            %{"name" => "page_size", "in" => "query", "schema" => %{"type" => "integer"}},
            %{
              "name" => "field_ids",
              "in" => "query",
              "style" => "form",
              "explode" => false,
              "schema" => %{"type" => "array", "items" => %{"type" => "string"}}
            },
            %{"name" => "siteId[]", "in" => "query", "x-castor-name" => "site_ids", "schema" => %{"type" => "string"}}
          ],
          "responses" => %{
            "200" => %{
              "content" => %{
                "application/hal+json" => %{
                  "schema" => %{
                    "type" => "object",
                    "properties" => %{
                      "_embedded" => %{
                        "type" => "object",
                        "properties" => %{
                          "sites" => %{"type" => "array", "items" => %{"$ref" => "#/components/schemas/Site"}}
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "post" => %{
          "operationId" => "create_site",
          "x-castor-module" => "Sites",
          "requestBody" => %{
            "required" => true,
            "content" => %{
              "application/json" => %{
                "schema" => %{
                  "type" => "object",
                  "required" => ["name"],
                  "properties" => %{"name" => %{"type" => "string"}, "abbreviation" => %{"type" => "string"}}
                }
              }
            }
          },
          "responses" => %{
            "201" => %{"content" => %{"application/json" => %{"schema" => %{"$ref" => "#/components/schemas/Site"}}}}
          }
        }
      },
      "/study/{study_id}/export/{id}/download" => %{
        "get" => %{
          "operationId" => "download_export",
          "x-castor-module" => "Exports",
          "parameters" => [
            %{"name" => "study_id", "in" => "path", "schema" => %{"type" => "string"}},
            %{"name" => "id", "in" => "path", "x-castor-name" => "export_id", "schema" => %{"type" => "string"}}
          ],
          "responses" => %{
            "200" => %{"content" => %{"application/zip" => %{"schema" => %{"type" => "string", "format" => "binary"}}}}
          }
        }
      },
      "/study/{study_id}/repeating-data-instance" => %{
        "get" => %{
          "operationId" => "list_repeating_data_instances",
          "x-castor-module" => "RepeatingData",
          "x-castor-items" => "_embedded.repeatingDataInstance",
          "x-castor-not-found-is-empty" => true,
          "responses" => %{"200" => %{}}
        }
      },
      "/study/{study_id}/participant/{participant_id}/data-points/study" => %{
        "post" => %{
          "operationId" => "upsert_study_data_points",
          "x-castor-module" => "DataPoints",
          "x-castor-partial-success" => true,
          "responses" => %{"201" => %{}}
        }
      }
    },
    "components" => %{
      "schemas" => %{
        "Site" => %{
          "type" => "object",
          "description" => "A site.",
          "required" => ["id"],
          "properties" => %{
            "id" => %{"type" => "string", "description" => "The site's ID"},
            "siteName" => %{"type" => "string"},
            "country_id" => %{"type" => "integer"},
            "created_on" => %{"$ref" => "#/components/schemas/DateTime"},
            "field_value" => %{"type" => "string", "x-castor-rename" => "value"},
            "value" => %{"type" => "string"},
            "tags" => %{"type" => "array", "items" => %{"$ref" => "#/components/schemas/Tag"}},
            "_links" => %{"$ref" => "#/components/schemas/LinksSingle"},
            "_embedded" => %{
              "type" => "object",
              "properties" => %{"country" => %{"$ref" => "#/components/schemas/Country"}}
            }
          }
        },
        "Tag" => %{"type" => "object", "properties" => %{"name" => %{"type" => "string"}}},
        "Country" => %{"type" => "object", "properties" => %{"name" => %{"type" => "string"}}},
        "DateTime" => %{"type" => "object", "x-castor-type" => "datetime", "properties" => %{"date" => %{}}},
        "LinksSingle" => %{"type" => "object", "properties" => %{"self" => %{}}},
        "Error" => %{"type" => "object", "properties" => %{"detail" => %{"type" => "string"}}}
      }
    }
  }

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

    assert Enum.map(list.query_params, &{&1.name, &1.wire, &1.list}) == [
             {"page", "page", false},
             {"page_size", "page_size", false},
             {"field_ids", "field_ids", true},
             {"site_ids", "siteId[]", false}
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
    assert operations["list_repeating_data_instances"].not_found_is_empty
    assert operations["upsert_study_data_points"].partial_success
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
             ["country", "country_id", "created_on", "id", "site_name", "tags", "value"]

    assert hd(models["Site"].fields).name == "id"
    assert fields["id"].required
    assert fields["id"].description == "The site's ID"
    assert fields["site_name"].wires == ["siteName"]
    assert fields["value"].wires == ["field_value", "value"]
    assert fields["created_on"].decode == {:cast, :datetime}
    assert fields["tags"].decode == {:list, CastorEDC.Model.Tag}
    assert fields["country"].decode == {:one, CastorEDC.Model.Country}
    assert fields["country"].wires == ["_embedded.country"]
    assert fields["country_id"].type == {:integer, nil}
  end

  test "refuses operations without a name or module" do
    document = put_in(@document, ["paths", "/study/{study_id}/site/{site_id}", "get", "operationId"], nil)
    assert_raise ArgumentError, ~r/no operationId/, fn -> Spec.parse(document) end
  end
end
