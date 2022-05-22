defmodule CastorEDCTest.DataCollection.Queries do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Queries

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "queries/queries#list" do
      {200, queries, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(queries["_embedded"]["queries"]) == 1
    end
  end

  test "find/3" do
    use_cassette "queries/queries#find" do
      {200, %{"id" => query_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "1C0B247E-3C2C-4506-BE88-5DDCF580F373"
        )

      assert query_id == "1C0B247E-3C2C-4506-BE88-5DDCF580F373"
    end
  end
end
