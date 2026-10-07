defmodule CastorEDC.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    Supervisor.start_link([CastorEDC.Application.Tables], strategy: :one_for_one, name: CastorEDC.Supervisor)
  end

  defmodule Tables do
    @moduledoc false
    # Owns the client's shared ETS tables: cached access tokens, keyed by
    # server and client ID, and the last known rate limit of every route. A
    # table lives as long as its owner, so the owner is a process of its own
    # under the supervisor.

    use GenServer

    @tables [:castor_edc_tokens, :castor_edc_rate_limits]

    def start_link(_options), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    @impl GenServer
    def init(nil) do
      for table <- @tables, do: :ets.new(table, [:named_table, :public, :set, read_concurrency: true])
      {:ok, nil}
    end
  end
end
