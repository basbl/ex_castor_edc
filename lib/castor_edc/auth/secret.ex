defmodule CastorEDC.Auth.Secret do
  @moduledoc false
  # A client secret, kept in the client so it can fetch tokens, but shown
  # as redacted whenever the client is inspected: in a log, an IEx session
  # or a notebook's output.

  @enforce_keys [:value]
  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @doc false
  @spec new(String.t()) :: t()
  def new(value) when is_binary(value), do: %__MODULE__{value: value}

  defimpl Inspect do
    def inspect(_secret, _opts), do: "#CastorEDC.Auth.Secret<redacted>"
  end
end
