defmodule CastorEDCTest.StudyProtocol.FieldValidations do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC.StudyProtocol.FieldValidations

  @client CastorEDC.Client.new(%{access_token: "supersecretaccesstoken"})

  test "list/2" do
    use_cassette "field_validations/field_validations#list" do
      {200, field_validations, _} = list(@client, "500475BC-F67A-41FD-A07D-4FF7C13756C8")

      assert length(field_validations["_embedded"]["fieldValidations"]) == 6
    end
  end

  test "find/3" do
    use_cassette "field_validations/field_validations#find" do
      {200, %{"id" => field_validation_id}, _} =
        find(
          @client,
          "500475BC-F67A-41FD-A07D-4FF7C13756C8",
          "6"
        )

      assert field_validation_id == 6
    end
  end
end
