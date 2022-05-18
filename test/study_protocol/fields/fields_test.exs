defmodule CastorEDCTest.StudyProtocol.Fields do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Fields

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/2" do
    use_cassette "fields/fields#list" do
      {200, fields, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(fields["_embedded"]["fields"]) == 25
    end
  end

  test "find/3" do
    use_cassette "fields/fields#find" do
      {200, %{"id" => field_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "4282728F-D112-4F96-99E2-2DDDFF012EC4"
        )

      assert field_id == "4282728F-D112-4F96-99E2-2DDDFF012EC4"
    end
  end
end
