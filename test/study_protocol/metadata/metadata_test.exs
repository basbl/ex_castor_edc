defmodule CastorEDCTest.StudyProtocol.Metadata do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Metadata

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "metadata/metadata#list" do
      {200, metadata, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(metadata["_embedded"]["metadatas"]) == 1
    end
  end

  test "find/3" do
    use_cassette "metadata/metadata#find" do
      {200, %{"id" => metadata_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "00F382C3-9ED6-4283-A0E1-98EA209C65FE"
        )

      assert metadata_id == "00F382C3-9ED6-4283-A0E1-98EA209C65FE"
    end
  end
end
