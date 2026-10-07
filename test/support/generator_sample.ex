defmodule CastorEDC.GeneratorSample do
  @moduledoc """
  A small OpenAPI document with an example of every shape the generator handles.
  """

  def document do
    %{
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
              "200" => %{
                "content" => %{"application/hal+json" => %{"schema" => %{"$ref" => "#/components/schemas/Site"}}}
              },
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
  end
end
