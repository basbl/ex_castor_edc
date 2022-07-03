defmodule CastorEDCTest.Middleware do
  use ExUnit.Case, async: true

  import CastorEDC

  @access_token "supersecretaccesstoken"
  @client CastorEDC.Client.access_token(@access_token)
  @expect_user_agent "elixir-ex_castor_edc/" <> Mix.Project.config()[:version]

  setup do
    Process.put(:mock_tesla_adapter, true)

    # This mock intercepts any request regardless of URL or method and always
    # return an empty 200 because for this set of tests, we don't actually care
    # about these aspects.
    #
    # We also send the passed in env (which contains the request within) back
    # to ourselves so that we can inspect it with `assert_receive`.
    #
    # For more information, see:
    #
    # - https://hexdocs.pm/tesla/Tesla.Mock.html
    # - https://github.com/elixir-tesla/tesla/wiki/Cookbook%3A-Testing-sent-requests
    Tesla.Mock.mock(fn env ->
      send(self(), {:env, env})
      %Tesla.Env{status: 200, body: "{}"}
    end)

    :ok
  end

  test "get sends correct headers" do
    {200, _, _} = get("api/", @client)

    assert_receive {:env,
                    %Tesla.Env{
                      headers: [
                        {"authorization", "Bearer " <> @access_token},
                        {"Accept", "application/json"},
                        {"User-Agent", @expect_user_agent}
                      ]
                    }}
  end

  test "post sends correct headers" do
    {200, _, _} = post("api/", @client, %{})

    assert_receive {:env,
                    %Tesla.Env{
                      headers: [
                        {"content-type", "application/json"},
                        {"authorization", "Bearer " <> @access_token},
                        {"Accept", "application/json"},
                        {"User-Agent", @expect_user_agent}
                      ]
                    }}
  end

  test "patch sends correct headers" do
    {200, _, _} = patch("api/", @client, %{})

    assert_receive {:env,
                    %Tesla.Env{
                      headers: [
                        {"content-type", "application/json"},
                        {"authorization", "Bearer " <> @access_token},
                        {"Accept", "application/json"},
                        {"User-Agent", @expect_user_agent}
                      ]
                    }}
  end
end
