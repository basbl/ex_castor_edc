defmodule CastorEDCTest.DataCollection.DataEntry.StudyDataPoint do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.DataEntry.StudyDataPoint

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/4" do
    use_cassette "study_data_point/study_data_point#list" do
      {200, data_points, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75", "110001")

      assert length(data_points["_embedded"]["StudyDataPoints"]) == 25
    end
  end

  test "find/4" do
    use_cassette "study_data_point/study_data_point#find" do
      {200, data_point, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "110001",
          "79F398C8-7B4A-49B4-8A60-85347EC176E6"
        )

      assert data_point["record_id"] == "110001"
      assert data_point["field_id"] == "79F398C8-7B4A-49B4-8A60-85347EC176E6"
    end
  end

  test "create/5" do
    use_cassette "study_data_point/study_data_point#create" do
      {201, data_point, _} =
        create(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "110004",
          "7BC52BB4-4848-4271-AE32-7AAD0ECE941F",
          %{"field_value" => "1984"}
        )

      assert data_point["record_id"] == "110004"
      assert data_point["field_id"] == "7BC52BB4-4848-4271-AE32-7AAD0ECE941F"
      assert data_point["value"] == "1984"
    end
  end
end
