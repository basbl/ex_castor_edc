defmodule CastorEDCTest.StudyProtocol.SurveyPackages do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.SurveyPackages

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "survey_packages/survey_packages#list" do
      {200, survey_packages, _} = list(@client, "C56B7E31-8984-438C-AAD8-E041AF4A09DC")

      assert length(survey_packages["_embedded"]["survey_packages"]) == 2
    end
  end

  test "find/3" do
    use_cassette "survey_packages/survey_packages#find" do
      {200, %{"id" => survey_package_id}, _} =
        find(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "21A81642-4A40-451F-A153-B6A9089E4AE6"
        )

      assert survey_package_id == "21A81642-4A40-451F-A153-B6A9089E4AE6"
    end
  end
end
