defmodule CastorEDCTest.DataCollection.SurveyPackageInstanceDataPointCollection do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  setup_all do
    HTTPoison.start()
  end

  test "list/3" do
    use_cassette "survey_package_instance_data_point_collection/survey_package_instance_data_point_collection#list" do
      {200, survey_package_instance_data_point_collection, _} =
        list(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "E8ECA57E-4204-4D22-85F5-10D8FF50913F"
        )

      assert length(survey_package_instance_data_point_collection["_embedded"]["items"]) == 4
    end
  end
end
