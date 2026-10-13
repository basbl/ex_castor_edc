defmodule CastorEDC.ErrorTest do
  use ExUnit.Case, async: true

  alias CastorEDC.Error

  defp response(status, body, headers \\ %{}) do
    Req.Response.new(status: status, body: body, headers: headers)
  end

  @problem "http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html"

  test "reads an RFC 7807 problem" do
    error =
      Error.from_response(
        response(404, %{
          "type" => @problem,
          "title" => "Not Found",
          "status" => 404,
          "detail" => "There are no repeating data instances."
        })
      )

    assert %Error{status: 404, message: "There are no repeating data instances.", code: nil, details: []} = error
  end

  test "reads the errors of a problem" do
    body = %{
      "type" => @problem,
      "title" => "Unprocessable Entity",
      "status" => 422,
      "errors" => [
        %{"http_code" => 422, "message" => "Invalid site", "error_code" => "INVALID_SITE", "id" => "a1b2c3d4"}
      ]
    }

    error = Error.from_response(response(422, body))

    assert error.message == "Invalid site"
    assert error.code == "INVALID_SITE"
    assert error.request_id == "a1b2c3d4"
    assert error.details == [%{code: "INVALID_SITE", message: "Invalid site", field: nil}]
  end

  test "reads the body of the layers in front of the endpoints" do
    body = %{
      "success" => false,
      "errors" => [
        %{"id" => "9f8e7d6c", "code" => "CODE_QUOTA_EXCEEDED", "message" => "Too many requests", "data" => []}
      ]
    }

    error = Error.from_response(response(429, body))

    assert %Error{status: 429, message: "Too many requests", code: "CODE_QUOTA_EXCEEDED", request_id: "9f8e7d6c"} =
             error
  end

  test "reads a body with only a reason" do
    error = Error.from_response(response(500, %{"success" => false, "reason" => "An error occurred."}))

    assert error.message == "An error occurred."
  end

  test "prefers a batch export's description over its generic detail" do
    body = %{
      "description" => "Number of requested concurrent exports exceeds configured maximum (3).",
      "type" => @problem,
      "title" => "Too Many Requests",
      "status" => 429,
      "detail" => "Too Many Requests"
    }

    assert Error.from_response(response(429, body)).message ==
             "Number of requested concurrent exports exceeds configured maximum (3)."
  end

  test "lists validation messages, in the message and as details" do
    body = %{
      "validation_messages" => %{
        "page_size" => %{"notBetween" => "The input is not between '1' and '1000', inclusively"}
      },
      "type" => @problem,
      "title" => "Unprocessable Entity",
      "status" => 422,
      "detail" => "Failed Validation"
    }

    error = Error.from_response(response(422, body))

    assert error.message == "Failed Validation: page_size: The input is not between '1' and '1000', inclusively"

    assert error.details == [
             %{code: "notBetween", message: "The input is not between '1' and '1000', inclusively", field: "page_size"}
           ]
  end

  test "decodes a problem that arrived as text" do
    body =
      ~s({"type": "#{@problem}", "title": "Not Acceptable", "status": 406, "detail": "Cannot honor Accept type specified"})

    assert Error.from_response(response(406, body)).message == "Cannot honor Accept type specified"
  end

  test "falls back to the status when the body says nothing" do
    assert Error.from_response(response(503, "")).message == "the Castor EDC API returned 503 Service Unavailable"
    assert Error.from_response(response(418, nil)).message == "the Castor EDC API returned 418"
  end

  test "keeps the response" do
    error = Error.from_response(response(404, %{"detail" => "Gone"}, %{"x-request" => ["1"]}))

    assert error.body == %{"detail" => "Gone"}
    assert error.headers == %{"x-request" => ["1"]}
  end

  test "wraps a transport failure" do
    exception = %Req.TransportError{reason: :timeout}
    error = Error.from_exception(exception)

    assert error.status == nil
    assert error.reason == exception
    assert error.message == Exception.message(exception)
  end

  test "is an exception" do
    assert_raise Error, "There are none.", fn ->
      raise Error.from_response(response(404, %{"detail" => "There are none."}))
    end
  end
end
