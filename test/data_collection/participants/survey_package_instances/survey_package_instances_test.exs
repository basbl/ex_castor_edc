defmodule CastorEDCTest.DataCollection.Participants.SurveyPackageInstances do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Participants.SurveyPackageInstances

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "patch/5" do
    use_cassette "participants/survey_package_instances/survey_package_instances#patch" do
      {200, survey_package_instance, _} =
        patch(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "110001",
          "E1330C42-F8A2-45B5-A76F-C776E7DECE5F",
          %{"started_on" => "2022-04-22 11:00:00"}
        )

      assert survey_package_instance["id"] == "E1330C42-F8A2-45B5-A76F-C776E7DECE5F"
    end
  end
end
