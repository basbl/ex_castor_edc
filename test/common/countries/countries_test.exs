defmodule CastorEDCTest.Common.Countries do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Countries

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/1" do
    use_cassette "countries/countries#list" do
      {200, countries, _} = list(@client)

      assert length(countries["results"]) == 250
    end
  end

  test "find/2" do
    use_cassette "countries/countries#find" do
      {200, %{"id" => country_id}, _} = find(@client, "2")

      assert country_id == 2
    end
  end
end
