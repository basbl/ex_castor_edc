defmodule CastorEDCTest.Common.Studies do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Studies

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/1" do
    use_cassette "studies/studies#list" do
      {200, studies, _} = list(@client)

      assert length(studies["_embedded"]["study"]) == 16
    end
  end

  test "find/2" do
    use_cassette "studies/studies#find" do
      {200, %{"name" => name}, _} = find(@client, "EB010EBB-A515-4395-AF66-4F83EAFF015C")
      assert name == "[CAS-11554] Send notifications on study/report/survey field update"
    end
  end
end
