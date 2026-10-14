defmodule CastorEDC.Case do
  @moduledoc """
  Tests with a `CastorEDC.Test` client, and the recorded fixtures.
  """

  use ExUnit.CaseTemplate

  import ExUnit.Assertions

  using do
    quote do
      import CastorEDC.Case
    end
  end

  defdelegate client(response, options \\ []), to: CastorEDC.Test
  defdelegate json(body, options \\ []), to: CastorEDC.Test

  @doc """
  The decoded contents of `test/fixtures/<name>.json`.
  """
  @spec fixture(String.t()) :: term()
  def fixture(name) do
    "test/fixtures"
    |> Path.join(name <> ".json")
    |> File.read!()
    |> JSON.decode!()
  end

  @doc """
  The request the client sent, failing the test if there was none.
  """
  @spec assert_requested(timeout()) :: Req.Request.t()
  def assert_requested(timeout \\ 100) do
    request = CastorEDC.Test.requested(timeout)
    assert request, "the client sent no request within #{timeout}ms"
    request
  end
end
