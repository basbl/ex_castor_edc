defmodule CastorEDC.Generator.Swagger2Test do
  use ExUnit.Case, async: true

  alias CastorEDC.Generator.Swagger2

  defp swagger(attrs) do
    Map.merge(
      %{
        "swagger" => "2.0",
        "info" => %{"title" => "API", "version" => "1"},
        "host" => "data.castoredc.com",
        "basePath" => "/api/",
        "schemes" => ["https"],
        "consumes" => ["application/json"],
        "produces" => ["application/hal+json"],
        "paths" => %{}
      },
      attrs
    )
  end

  defp operation(document, path, method \\ "get") do
    Swagger2.convert!(document)["paths"][path][method]
  end

  test "turns host, base path and schemes into servers" do
    converted = Swagger2.convert!(swagger(%{}))

    assert converted["openapi"] == "3.1.0"
    assert converted["info"] == %{"title" => "API", "version" => "1"}
    assert converted["servers"] == [%{"url" => "https://data.castoredc.com/api"}]
  end

  test "moves definitions to components and rewrites references, sanitising names" do
    document =
      swagger(%{
        "definitions" => %{
          "Not Acceptable" => %{"type" => "object"},
          "Study" => %{"type" => "object", "properties" => %{"error" => %{"$ref" => "#/definitions/Not Acceptable"}}}
        },
        "paths" => %{
          "/study" => %{
            "get" => %{
              "responses" => %{"200" => %{"description" => "OK", "schema" => %{"$ref" => "#/definitions/Study"}}}
            }
          }
        }
      })

    converted = Swagger2.convert!(document)

    assert Map.keys(converted["components"]["schemas"]) == ["Not_Acceptable", "Study"]

    assert converted["components"]["schemas"]["Study"]["properties"]["error"] == %{
             "$ref" => "#/components/schemas/Not_Acceptable"
           }

    assert converted["paths"]["/study"]["get"]["responses"]["200"] == %{
             "description" => "OK",
             "content" => %{"application/hal+json" => %{"schema" => %{"$ref" => "#/components/schemas/Study"}}}
           }
  end

  test "keeps responses without a schema as they are, and uses an operation's own produces" do
    document =
      swagger(%{
        "paths" => %{
          "/export/{id}/download" => %{
            "get" => %{
              "produces" => ["application/zip"],
              "responses" => %{
                "200" => %{"description" => "File", "schema" => %{"type" => "file"}},
                "404" => %{"description" => "Not found"}
              }
            }
          }
        }
      })

    assert operation(document, "/export/{id}/download")["responses"] == %{
             "200" => %{
               "description" => "File",
               "content" => %{"application/zip" => %{"schema" => %{"type" => "string", "format" => "binary"}}}
             },
             "404" => %{"description" => "Not found"}
           }
  end

  test "moves parameter types into a schema and collection formats into style and explode" do
    parameters = [
      %{"name" => "study_id", "in" => "path", "required" => true, "type" => "string", "format" => "UUID"},
      %{"name" => "page", "in" => "query", "type" => "integer", "default" => 1, "description" => "Page"},
      %{
        "name" => "ids",
        "in" => "query",
        "type" => "array",
        "items" => %{"type" => "string"},
        "collectionFormat" => "csv"
      },
      %{
        "name" => "tags",
        "in" => "query",
        "type" => "array",
        "items" => %{"type" => "string"},
        "collectionFormat" => "multi"
      }
    ]

    document =
      swagger(%{"paths" => %{"/study/{study_id}" => %{"get" => %{"parameters" => parameters, "responses" => %{}}}}})

    assert operation(document, "/study/{study_id}")["parameters"] == [
             %{
               "name" => "study_id",
               "in" => "path",
               "required" => true,
               "schema" => %{"type" => "string", "format" => "UUID"}
             },
             %{
               "name" => "page",
               "in" => "query",
               "description" => "Page",
               "schema" => %{"type" => "integer", "default" => 1}
             },
             %{
               "name" => "ids",
               "in" => "query",
               "schema" => %{"type" => "array", "items" => %{"type" => "string"}},
               "style" => "form",
               "explode" => false
             },
             %{
               "name" => "tags",
               "in" => "query",
               "schema" => %{"type" => "array", "items" => %{"type" => "string"}},
               "style" => "form",
               "explode" => true
             }
           ]
  end

  test "turns a body parameter into a request body for each consumed media type" do
    body = %{
      "name" => "body",
      "in" => "body",
      "required" => true,
      "description" => "The site",
      "schema" => %{"$ref" => "#/definitions/Site"}
    }

    document =
      swagger(%{
        "definitions" => %{"Site" => %{"type" => "object"}},
        "paths" => %{"/site" => %{"post" => %{"parameters" => [body], "responses" => %{}}}}
      })

    converted = operation(document, "/site", "post")

    refute Map.has_key?(converted, "parameters")

    assert converted["requestBody"] == %{
             "description" => "The site",
             "required" => true,
             "content" => %{"application/json" => %{"schema" => %{"$ref" => "#/components/schemas/Site"}}}
           }
  end

  test "turns form parameters into a multipart body when one is a file" do
    parameters = [
      %{"name" => "field_value", "in" => "formData", "type" => "string", "required" => true},
      %{"name" => "upload_file", "in" => "formData", "type" => "file", "description" => "The file"}
    ]

    document = swagger(%{"paths" => %{"/data-point" => %{"post" => %{"parameters" => parameters, "responses" => %{}}}}})

    assert operation(document, "/data-point", "post")["requestBody"] == %{
             "required" => true,
             "content" => %{
               "multipart/form-data" => %{
                 "schema" => %{
                   "type" => "object",
                   "required" => ["field_value"],
                   "properties" => %{
                     "field_value" => %{"type" => "string"},
                     "upload_file" => %{"type" => "string", "format" => "binary", "description" => "The file"}
                   }
                 }
               }
             }
           }
  end

  test "turns form parameters without a file into a URL-encoded body" do
    parameters = [%{"name" => "reason", "in" => "formData", "type" => "string"}]
    document = swagger(%{"paths" => %{"/lock" => %{"post" => %{"parameters" => parameters, "responses" => %{}}}}})

    assert %{"content" => %{"application/x-www-form-urlencoded" => _content}} =
             operation(document, "/lock", "post")["requestBody"]
  end

  test "converts nullable and nested schemas" do
    document =
      swagger(%{
        "definitions" => %{
          "Field" => %{
            "type" => "object",
            "properties" => %{
              "label" => %{"type" => "string", "x-nullable" => true},
              "options" => %{"type" => "array", "items" => %{"$ref" => "#/definitions/Option"}},
              "extra" => %{"type" => "object", "additionalProperties" => %{"$ref" => "#/definitions/Option"}}
            }
          },
          "Option" => %{"allOf" => [%{"$ref" => "#/definitions/Base"}, %{"type" => "object"}]},
          "Base" => %{"type" => "object"}
        }
      })

    schemas = Swagger2.convert!(document)["components"]["schemas"]

    assert schemas["Field"]["properties"]["label"] == %{"type" => ["string", "null"]}
    assert schemas["Field"]["properties"]["options"]["items"] == %{"$ref" => "#/components/schemas/Option"}
    assert schemas["Field"]["properties"]["extra"]["additionalProperties"] == %{"$ref" => "#/components/schemas/Option"}
    assert schemas["Option"]["allOf"] == [%{"$ref" => "#/components/schemas/Base"}, %{"type" => "object"}]
  end

  test "converts the OAuth2 application flow to client credentials" do
    scheme = %{
      "type" => "oauth2",
      "flow" => "application",
      "tokenUrl" => "https://data.castoredc.com/oauth/token",
      "scopes" => %{"default" => "Everything"}
    }

    document = swagger(%{"securityDefinitions" => %{"OAuth2" => scheme}, "security" => [%{"OAuth2" => ["default"]}]})
    converted = Swagger2.convert!(document)

    assert converted["components"]["securitySchemes"]["OAuth2"] == %{
             "type" => "oauth2",
             "flows" => %{
               "clientCredentials" => %{
                 "tokenUrl" => "https://data.castoredc.com/oauth/token",
                 "scopes" => %{"default" => "Everything"}
               }
             }
           }

    assert converted["security"] == [%{"OAuth2" => ["default"]}]
  end

  test "keeps operation details and extensions" do
    get = %{
      "summary" => "List",
      "tags" => ["study"],
      "deprecated" => true,
      "operationId" => "list_studies",
      "x-castor-module" => "Studies",
      "responses" => %{}
    }

    assert operation(swagger(%{"paths" => %{"/study" => %{"get" => get}}}), "/study") == get
  end

  test "rejects what it doesn't convert" do
    assert_raise ArgumentError, fn -> Swagger2.convert!(%{"openapi" => "3.0.0"}) end

    assert_raise ArgumentError, ~r/path item \/ isn't an object/, fn ->
      Swagger2.convert!(swagger(%{"paths" => %{"/" => []}}))
    end

    cookie_parameter = %{"name" => "x", "in" => "cookie", "type" => "string"}

    assert_raise ArgumentError, fn ->
      Swagger2.convert!(
        swagger(%{"paths" => %{"/a" => %{"get" => %{"parameters" => [cookie_parameter], "responses" => %{}}}}})
      )
    end
  end
end
