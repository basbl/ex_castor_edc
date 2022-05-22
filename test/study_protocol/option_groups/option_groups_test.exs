defmodule CastorEDCTest.StudyProtocol.OptionGroups do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.OptionGroups

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  test "list/2" do
    use_cassette "option_groups/option_groups#list" do
      {200, option_groups, _} = list(@client, "AFE56D62-0797-406B-9949-DD8DC65D6A75", page: 1)

      assert length(option_groups["_embedded"]["fieldOptionGroups"]) == 25
    end
  end

  test "find/3" do
    use_cassette "option_groups/option_groups#find" do
      {200, %{"id" => option_group_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "02F149C6-A94E-45DD-93E8-E9849C36692F"
        )

      assert option_group_id == "02F149C6-A94E-45DD-93E8-E9849C36692F"
    end
  end
end
