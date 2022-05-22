defmodule CastorEDCTest.DataCollection.Verifications do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Verifications

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "verifications/verifications#list" do
      {200, verifications, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(verifications["_embedded"]["verifications"]) == 6
    end
  end
end
