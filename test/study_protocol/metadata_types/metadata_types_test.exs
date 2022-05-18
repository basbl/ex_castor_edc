defmodule CastorEDCTest.StudyProtocol.MetadataTypes do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.MetadataTypes

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/2" do
    use_cassette "metadata_types/metadata_types#list" do
      {200, metadata_types, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(metadata_types["_embedded"]["metadatatypes"]) == 1
    end
  end

  test "find/3" do
    use_cassette "metadata_types/metadata_types#find" do
      {200, %{"id" => metadata_type_id}, _} =
        find(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8", "1")

      assert metadata_type_id == 1
    end
  end
end
