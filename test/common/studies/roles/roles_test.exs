defmodule CastorEDCTest.Common.Studies.Roles do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Studies.Roles

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "studies/roles/roles#list" do
      {200, roles, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75")

      assert length(roles["_embedded"]["roles"]) == 3
    end
  end

  test "find/2" do
    use_cassette "studies/roles/roles#find" do
      {200, role, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "Admin"
        )

      assert role["name"] == "Admin"
    end
  end

  test "create/3" do
    use_cassette "studies/roles/roles#create" do
      expected = %{
        "name" => "NewCustomRole",
        "description" => "Role added through the API",
        "permissions" => %{
          "add" => true,
          "delete" => true,
          "edit" => false,
          "email_addresses" => true,
          "export" => false,
          "lock" => true,
          "query" => false,
          "randomization_read" => true,
          "randomization_write" => false,
          "sdv" => true,
          "sign" => false,
          "survey_send" => true,
          "survey_view" => false,
          "televisit" => true,
          "view" => true
        }
      }

      {201, role, _} =
        create(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          expected
        )

      assert role["name"] == expected["name"]
    end
  end
end
