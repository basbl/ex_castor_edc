defmodule CastorEDCTest.DataCollection.Statistics do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Statistics

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "find/2" do
    use_cassette "statistics/statistics#find" do
      {200, statistics, _} = find(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert statistics["study_id"] == "AFE56D62-0797-406B-9949-DD8DC65D6A75"
    end
  end
end
