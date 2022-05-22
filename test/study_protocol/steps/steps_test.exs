defmodule CastorEDCTest.StudyProtocol.Steps do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.Steps

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "steps/steps#list" do
      {200, steps, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(steps["_embedded"]["steps"]) == 7
    end
  end

  test "find/3" do
    use_cassette "steps/steps#find" do
      {200, %{"id" => step_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "E30A339F-0470-451C-B8EF-115B53D8F76B"
        )

      assert step_id == "E30A339F-0470-451C-B8EF-115B53D8F76B"
    end
  end
end
