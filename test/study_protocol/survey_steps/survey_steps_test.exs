defmodule CastorEDCTest.StudyProtocol.SurveySteps do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.SurveySteps

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "survey_steps/survey_steps#list" do
      {200, survey_steps, _} =
        list(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "83F352DC-816B-4387-A13E-6D716D44AE83"
        )

      assert length(survey_steps["_embedded"]["survey_steps"]) == 1
    end
  end

  test "find/3" do
    use_cassette "survey_steps/survey_steps#find" do
      {200, %{"id" => survey_step_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "83F352DC-816B-4387-A13E-6D716D44AE83",
          "3F22E3E8-E3BB-43D0-9C9C-F1DE67B95B18"
        )

      assert survey_step_id == "3F22E3E8-E3BB-43D0-9C9C-F1DE67B95B18"
    end
  end
end
