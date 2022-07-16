defmodule CastorEDCTest.DataCollection.ReportInstances do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.ReportInstances

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "report_instances/report_instances#list" do
      {200, report_instances, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75", page: 1)

      assert length(report_instances["_embedded"]["reportInstances"]) == 1
    end
  end

  test "find/3" do
    use_cassette "report_instances/report_instances#find" do
      {200, %{"id" => report_instance_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "98CFD906-7D4D-43C8-8E83-AC26DBB8BDD5"
        )

      assert report_instance_id == "98CFD906-7D4D-43C8-8E83-AC26DBB8BDD5"
    end
  end
end
