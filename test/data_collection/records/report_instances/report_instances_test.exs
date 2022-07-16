defmodule CastorEDCTest.DataCollection.Records.ReportInstances do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Records.ReportInstances

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/4" do
    use_cassette "records/report_instances/report_instances#list" do
      {200, report_instances, _} = list(@client, "C56B7E31-8984-438C-AAD8-E041AF4A09DC", "110001")

      assert length(report_instances["_embedded"]["reportInstances"]) == 4
    end
  end

  test "find/4" do
    use_cassette "records/report_instances/report_instances#find" do
      {200, report_instance, _} =
        find(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "110001",
          "3306FAD0-AEB8-4F4A-932D-AD936F7FE212"
        )

      assert report_instance["id"] == "3306FAD0-AEB8-4F4A-932D-AD936F7FE212"
    end
  end

  test "create/4 single instance" do
    use_cassette "records/report_instances/report_instances#create-single" do
      {201, report_instance, _} =
        create(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "110001",
          %{"report_id" => "738DDB4C-E1E2-42C3-8C21-DA8903EEF1F3"}
        )

      assert report_instance["id"] == "95CD85E1-45BD-42EE-90EA-8C3A5F3FAC00"
    end
  end

  test "create/4 multiple instances" do
    use_cassette "records/report_instances/report_instances#create-multiple" do
      {201, %{"success" => report_instances}, _} =
        create(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "110001",
          [
            %{"report_id" => "738DDB4C-E1E2-42C3-8C21-DA8903EEF1F3"},
            %{"report_id" => "BE71F4D5-64E2-493E-9D9B-18A215A493D3"}
          ]
        )

      assert length(report_instances) == 2
    end
  end
end
