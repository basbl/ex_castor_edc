defmodule CastorEDCTest.StudyProtocol.Phases do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Phases

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "phases/phases#list" do
      {200, phases, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(phases["_embedded"]["phases"]) == 4
    end
  end

  test "find/3" do
    use_cassette "phases/phases#find" do
      {200, %{"id" => phase_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "7808FFAB-6B69-4DD6-8E5F-DDF2D5D0115A"
        )

      assert phase_id == "7808FFAB-6B69-4DD6-8E5F-DDF2D5D0115A"
    end
  end
end
