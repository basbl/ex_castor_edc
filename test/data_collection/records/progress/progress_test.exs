defmodule CastorEDCTest.DataCollection.Records.Progress do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Records.Progress

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/2" do
    use_cassette "records/progress/progress#list" do
      {200, records, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(records["_embedded"]["records"]) == 25
    end
  end
end
