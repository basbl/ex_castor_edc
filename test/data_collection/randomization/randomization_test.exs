defmodule CastorEDCTest.DataCollection.Randomization do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.DataCollection.Randomization

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "find/3" do
    use_cassette "randomization/randomization#find" do
      {200, %{"randomized_id" => randomized_id}, _} =
        find(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "110001"
        )

      assert randomized_id == "001"
    end
  end

  test "create/3" do
    use_cassette "randomization/randomization#create" do
      {201, %{"randomized_id" => randomized_id}, _} =
        create(
          @client,
          "AFE56D62-0797-406B-9949-DD8DC65D6A75",
          "110003"
        )

      assert randomized_id == "002"
    end
  end
end
