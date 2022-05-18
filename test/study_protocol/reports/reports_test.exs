defmodule CastorEDCTest.StudyProtocol.Reports do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Reports

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/2" do
    use_cassette "reports/reports#list" do
      {200, reports, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(reports["_embedded"]["reports"]) == 4
    end
  end

  test "find/3" do
    use_cassette "reports/reports#find" do
      {200, %{"id" => report_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "07362069-A506-43F0-BB92-A82FF5C46D59"
        )

      assert report_id == "07362069-A506-43F0-BB92-A82FF5C46D59"
    end
  end
end
