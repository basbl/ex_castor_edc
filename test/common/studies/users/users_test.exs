defmodule CastorEDCTest.Common.Studies.Users do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Studies.Users

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "studies/users/users#list" do
      {200, users, _} = list(@client, "7AD4616E-B169-4F9E-9982-F626099B84C0")

      assert users["total_items"] == 1
    end
  end

  test "find/2" do
    use_cassette "studies/users/users#find" do
      {200, user, _} =
        find(
          @client,
          "7AD4616E-B169-4F9E-9982-F626099B84C0",
          "8F654747-3561-4C90-BD8F-B21320DA7862"
        )

      assert user["user_id"] == "8F654747-3561-4C90-BD8F-B21320DA7862"
    end
  end
end
