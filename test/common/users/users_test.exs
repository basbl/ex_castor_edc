defmodule CastorEDCTest.Common.Users do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.Common.Users

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/1" do
    use_cassette "users/users#list" do
      {200, users, _} = list(@client)

      assert length(users["_embedded"]["user"]) == 1
    end
  end

  test "find/2" do
    use_cassette "users/users#find" do
      {200, %{"id" => id}, _} = find(@client, "D6A16E39-B3CE-4441-BD7A-43AA1B53A43E")
      assert id == "D6A16E39-B3CE-4441-BD7A-43AA1B53A43E"
    end
  end
end
