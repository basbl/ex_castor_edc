defmodule CastorEDCTest.StudyProtocol.ReportSteps do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.ReportSteps

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "report_steps/report_steps#list" do
      {200, report_steps, _} =
        list(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "07362069-A506-43F0-BB92-A82FF5C46D59"
        )

      assert length(report_steps["_embedded"]["report_steps"]) == 2
    end
  end

  test "find/3" do
    use_cassette "report_steps/report_steps#find" do
      {200, %{"id" => report_step_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "07362069-A506-43F0-BB92-A82FF5C46D59",
          "0EFBA357-F714-4AE7-A6C9-155570EF3B3D"
        )

      assert report_step_id == "0EFBA357-F714-4AE7-A6C9-155570EF3B3D"
    end
  end
end
