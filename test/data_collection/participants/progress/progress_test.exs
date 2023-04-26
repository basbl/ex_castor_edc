defmodule CastorEDCTest.DataCollection.Participants.Progress do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Participants.Progress

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "participants/progress/progress#list" do
      {200, records, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(records["_embedded"]["records"]) == 25
    end
  end
end
