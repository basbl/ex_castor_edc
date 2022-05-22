defmodule CastorEDCTest.StudyProtocol.Surveys do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Surveys

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "surveys/surveys#list" do
      {200, surveys, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(surveys["_embedded"]["surveys"]) == 2
    end
  end

  test "find/3" do
    use_cassette "surveys/surveys#find" do
      {200, %{"id" => survey_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "83F352DC-816B-4387-A13E-6D716D44AE83"
        )

      assert survey_id == "83F352DC-816B-4387-A13E-6D716D44AE83"
    end
  end
end
