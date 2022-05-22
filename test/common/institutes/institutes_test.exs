defmodule CastorEDCTest.Common.Institutes do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Institutes

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "institutes/institutes#list" do
      {200, institutes, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(institutes["_embedded"]["institutes"]) == 5
    end
  end

  test "find/3" do
    use_cassette "institutes/institutes#find" do
      {200, %{"id" => institutes_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "87B0E37F-2403-491A-8313-7B9EE1C0AB77"
        )

      assert institutes_id == "87B0E37F-2403-491A-8313-7B9EE1C0AB77"
    end
  end

  test "create/3 single" do
    use_cassette "institutes/institutes#create_single" do
      {201, %{"success" => [institute]}, _} =
        create(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8", %{
          abbreviation: "CSTR",
          country_id: "169",
          name: "Castor"
        })

      assert institute["name"] == "Castor"
    end
  end

  test "create/3 multiple" do
    use_cassette "institutes/institutes#create_multiple" do
      {201, %{"success" => [institute1 | [institute2]]}, _} =
        create(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8", [
          %{
            abbreviation: "CSTR1",
            country_id: "169",
            name: "Castor 1"
          },
          %{
            abbreviation: "CSTR2",
            country_id: "169",
            name: "Castor 2"
          }
        ])

      assert institute1["name"] == "Castor 1"
      assert institute2["name"] == "Castor 2"
    end
  end
end
