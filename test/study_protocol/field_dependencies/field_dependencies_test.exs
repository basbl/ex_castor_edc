defmodule CastorEDCTest.StudyProtocol.FieldDependencies do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.FieldDependencies

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "field_dependencies/field_dependencies#list" do
      {200, field_dependencies, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(field_dependencies["_embedded"]["fieldDependencies"]) == 6
    end
  end

  test "find/3" do
    use_cassette "field_dependencies/field_dependencies#find" do
      {200, %{"id" => field_dependency_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "6"
        )

      assert field_dependency_id == 6
    end
  end
end
