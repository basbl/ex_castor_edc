defmodule CastorEDCTest.ConnectionErrors do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import CastorEDC

  @client CastorEDC.Client.access_token("supersecretaccesstoken")

  # These tests verify that we will return `{:error, :reason}` tuples on
  # non-HTTP related errors, like timeouts and refused connetions.
  #
  # In reality, :reason is an atom (at least with Hackney, this may be
  # adapter-specific behavior?), however due to a quirk in ExVCR these atoms
  # are converted to strings on save:
  #
  # https://github.com/parroty/exvcr/blob/69aaa49c83de34814dc66253e5819583077cf145/lib/exvcr/adapter/hackney/converter.ex#L96-L101
  #
  # ..but not converted back from string to atom on load/restore:
  #
  # https://github.com/parroty/exvcr/blob/69aaa49c83de34814dc66253e5819583077cf145/lib/exvcr/adapter/hackney/converter.ex#L8-L21
  #
  # As such these tests pattern-match on strings while in reality, end-users
  # should pattern-match on atoms.

  test "get" do
    use_cassette "errors/get" do
      {:error, "econnrefused"} = get("api/", @client)
    end
  end

  test "post" do
    use_cassette "errors/post" do
      {:error, "econnrefused"} = post("api/", @client, %{})
    end
  end

  test "patch" do
    use_cassette "errors/patch" do
      {:error, "econnrefused"} = patch("api/", @client, %{})
    end
  end

  test "authenticate" do
    use_cassette "errors/authenticate" do
      client =
        CastorEDC.Client.new(
          "0b362196-09ad-4d09-b5bf-27a515bbc358",
          "secret"
        )

      {:error, "econnrefused"} = CastorEDC.authenticate(client)
    end
  end
end
