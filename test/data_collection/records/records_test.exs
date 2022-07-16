defmodule CastorEDCTest.DataCollection.Records do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Records

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "records/records#list" do
      {200, records, _} = list(@client, "4C1FBBE5-B9D7-421B-90B3-D5E2E7AF394F")

      assert length(records["_embedded"]["records"]) == 1
    end
  end

  test "find/3" do
    use_cassette "records/records#find" do
      {200, %{"id" => record_id}, _} =
        find(@client, "4C1FBBE5-B9D7-421B-90B3-D5E2E7AF394F", "110001")

      assert record_id == "110001"
    end
  end

  test "create/3" do
    use_cassette "records/records#create" do
      {201, %{"id" => record_id}, _} =
        create(@client, "7AD4616E-B169-4F9E-9982-F626099B84C0", %{
          institute_id: "44A6D11D-84B5-4983-9B32-C06297349193",
          email_address: "example.user@example.org"
        })

      assert record_id == "000001"
    end
  end
end
