defmodule CastorEDCTest.DataCollection.ReportInstanceDataPointCollection do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.DataPoints.ReportInstanceDataPointCollection

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/2" do
    use_cassette "report_instance_data_point_collection/report_instance_data_point_collection#list" do
      {200, report_instance_data_point_collection, _} =
        list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(report_instance_data_point_collection["_embedded"]["items"]) == 10
    end
  end

  test "find/3" do
    use_cassette "report_instance_data_point_collection/report_instance_data_point_collection#find" do
      {200, report_instance_data_point_collection, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "C818FFC2-0FB8-4DDE-9317-231D99B1F453"
        )

      assert length(report_instance_data_point_collection["_embedded"]["items"]) == 9
    end
  end
end
