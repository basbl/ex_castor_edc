defmodule CastorEDCTest.DataCollection.StudyDataPointCollection do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.DataPoints.StudyDataPointCollection

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "study_data_point_collection/study_data_point_collection#list" do
      {200, study_data_point_collection, _} =
        list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(study_data_point_collection["_embedded"]["items"]) == 6
    end
  end
end
