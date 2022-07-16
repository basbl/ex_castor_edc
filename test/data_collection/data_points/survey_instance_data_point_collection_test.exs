defmodule CastorEDCTest.DataCollection.SurveyInstanceDataPointCollection do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "survey_instance_data_point_collection/survey_instance_data_point_collection#list" do
      {200, survey_instance_data_point_collection, _} =
        list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(survey_instance_data_point_collection["_embedded"]["items"]) == 4
    end
  end

  test "find/3" do
    use_cassette "survey_instance_data_point_collection/survey_instance_data_point_collection#find" do
      {200, survey_instance_data_point_collection, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "478ABB09-F259-4C53-A02E-B91B12F55F69"
        )

      assert length(survey_instance_data_point_collection["_embedded"]["items"]) == 4
    end
  end
end
