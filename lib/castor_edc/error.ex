defmodule CastorEDC.Error do
  @moduledoc """
  A failed request: one the API refused, or one that never got an answer.

  Every operation returns `{:error, %CastorEDC.Error{}}` rather than raising,
  and the `!` variants raise it. `status` tells the two kinds apart: a
  refused request has the HTTP status, while a request that failed in
  transit has `nil` and the underlying exception in `reason`.

  The API answers errors with several kinds of body: an RFC 7807 problem
  from inside an endpoint (with validation messages for some), and
  `{"success": false, "errors": [...]}` or `{"success": false, "reason": ...}`
  from the layers in front of it, such as rate limiting. Whichever arrives,
  the useful parts end up in the same fields:

    * `message` - what went wrong, in a sentence
    * `code` - the API's error code, such as `"CODE_QUOTA_EXCEEDED"`, when
      it gives one, or an atom for errors the client recognises itself
    * `details` - each individual error, as `%{code:, message:, field:}`
      maps (`field` is set for validation messages)
    * `request_id` - a reference Castor support can trace
    * `body` and `headers` - the response as it arrived
  """

  @enforce_keys [:message]
  defexception [
    :message,
    :status,
    :code,
    :request_id,
    :body,
    :headers,
    :reason,
    :retry_after,
    details: [],
    rate_limit: nil
  ]

  @type t :: %__MODULE__{
          message: String.t(),
          status: 100..599 | nil,
          code: String.t() | atom() | nil,
          details: [%{code: String.t() | nil, message: String.t() | nil, field: String.t() | nil}],
          request_id: String.t() | nil,
          body: term(),
          headers: %{optional(String.t()) => [String.t()]} | nil,
          reason: term(),
          retry_after: non_neg_integer() | nil,
          rate_limit: map() | nil
        }

  @phrases %{
    400 => "Bad Request",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    405 => "Method Not Allowed",
    406 => "Not Acceptable",
    409 => "Conflict",
    410 => "Gone",
    416 => "Range Not Satisfiable",
    422 => "Unprocessable Entity",
    429 => "Too Many Requests",
    500 => "Internal Server Error",
    503 => "Service Unavailable"
  }

  @doc false
  @spec from_response(Req.Response.t()) :: t()
  def from_response(%Req.Response{status: status, body: body, headers: headers}) do
    body = decode(body)
    errors = errors(body)
    validation = validation_details(body)

    %__MODULE__{
      message: message(body, errors, validation, status),
      status: status,
      code: first(errors, ["error_code", "code"]),
      details: Enum.map(errors, &detail/1) ++ validation,
      request_id: first(errors, ["id"]),
      body: body,
      headers: headers
    }
  end

  @doc false
  @spec from_exception(Exception.t()) :: t()
  def from_exception(exception) do
    %__MODULE__{message: Exception.message(exception), reason: exception}
  end

  # A body Req couldn't decode, such as a problem served as text/html.
  defp decode(body) when is_binary(body) do
    case JSON.decode(body) do
      {:ok, decoded} when is_map(decoded) -> decoded
      _not_json -> body
    end
  end

  defp decode(body), do: body

  defp errors(%{"errors" => errors}) when is_list(errors), do: Enum.filter(errors, &is_map/1)
  defp errors(_body), do: []

  defp validation_details(%{"validation_messages" => messages}) when is_map(messages) do
    for {field, rules} <- messages, {rule, text} <- validation_rules(rules) do
      %{code: rule, message: text, field: field}
    end
  end

  defp validation_details(_body), do: []

  defp validation_rules(rules) when is_map(rules), do: Enum.map(rules, fn {rule, text} -> {rule, to_string(text)} end)
  defp validation_rules(text), do: [{nil, to_string(text)}]

  # Batch export errors put a generic text in `detail` and the useful one in
  # `description`; validation failures say "Failed Validation" and list the
  # reasons separately.
  defp message(body, errors, validation, status) do
    text =
      first_text(body, ["description", "detail"]) || first(errors, ["message"]) ||
        first_text(body, ["reason", "title"]) || default_message(status)

    case validation do
      [] -> text
      details -> text <> ": " <> Enum.map_join(details, "; ", &"#{&1.field}: #{&1.message}")
    end
  end

  defp first_text(body, keys) when is_map(body) do
    Enum.find_value(keys, fn key ->
      case body[key] do
        text when is_binary(text) and text != "" -> text
        _missing -> nil
      end
    end)
  end

  defp first_text(_body, _keys), do: nil

  defp first([error | _rest], keys), do: first_text(error, keys)
  defp first([], _keys), do: nil

  defp detail(error) do
    %{code: first_text(error, ["error_code", "code"]), message: first_text(error, ["message"]), field: nil}
  end

  defp default_message(status) do
    case @phrases do
      %{^status => phrase} -> "the Castor EDC API returned #{status} #{phrase}"
      _other -> "the Castor EDC API returned #{status}"
    end
  end
end
