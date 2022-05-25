defmodule CastorEDCTest.DataCollection.SurveyPackageInstances do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.SurveyPackageInstances

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "data_collection/survey_package_instances#list" do
      {200, survey_package_instances, _} =
        list(@client, "C56B7E31-8984-438C-AAD8-E041AF4A09DC", page: 1)

      assert length(survey_package_instances["_embedded"]["surveypackageinstance"]) == 3
    end
  end

  test "find/3" do
    use_cassette "data_collection/survey_package_instances#find" do
      {200, %{"id" => survey_package_instance_id}, _} =
        find(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "E1330C42-F8A2-45B5-A76F-C776E7DECE5F"
        )

      assert survey_package_instance_id == "E1330C42-F8A2-45B5-A76F-C776E7DECE5F"
    end
  end

  test "create/3" do
    use_cassette "data_collection/survey_package_instances#create" do
      {201, %{"id" => survey_package_instance_id}, _} =
        create(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          %{
            "record_id" => "110001",
            "survey_package_id" => "21A81642-4A40-451F-A153-B6A9089E4AE6",
            "email_address" => "jane.doe@example.org",
            "package_invitation_subject" => "Your first survey",
            "package_invitation" => "Please follow the link: {url}",
            "auto_send" => true,
            "auto_lock_on_finish" => true
          }
        )

      assert survey_package_instance_id == "959D4D68-8357-483F-81B5-20E4653D08C3"
    end
  end

  test "patch/4" do
    use_cassette "data_collection/survey_package_instances#patch" do
      {200, %{"id" => survey_package_instance_id}, _} =
        patch(
          @client,
          "C56B7E31-8984-438C-AAD8-E041AF4A09DC",
          "959D4D68-8357-483F-81B5-20E4653D08C3",
          %{
            "locked" => true
          }
        )

      assert survey_package_instance_id == "959D4D68-8357-483F-81B5-20E4653D08C3"
    end
  end
end
