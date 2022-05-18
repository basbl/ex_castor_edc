defmodule CastorEDC.Common.Countries do
  @moduledoc """
  Provides access to country related endpoints
  """

  import CastorEDC
  alias CastorEDC.Client

  @doc """
  List all available countries

  [More info](https://data.castoredc.com/api#/country/get_country)
  """
  def list(%Client{} = client) do
    get("api/country", client)
  end

  @doc """
  Find a specific country

  [More info](https://data.castoredc.com/api#/country/get_country__country_id_)
  """
  def find(%Client{} = client, country_id) do
    get("api/country/" <> country_id, client)
  end
end
