defmodule Mix.Tasks.CastorEdc.Fixtures.RecordTest do
  # Not async: reads and changes the OS environment.
  use ExUnit.Case, async: false

  alias Mix.Tasks.CastorEdc.Fixtures.Record

  test "scrubs e-mail addresses and personal names" do
    response = %{
      "full_name" => "Jane Doe",
      "name_first" => "Jane",
      "name" => "Test Site",
      "email_address" => "jane.doe@hospital.example.net",
      "invitation" => "Write to jane@hospital.org or info@example.org",
      "_embedded" => %{"users" => [%{"name_last" => "Doe", "name_middle" => ""}]}
    }

    assert Record.scrub(response) == %{
             "full_name" => "Test User",
             "name_first" => "Test User",
             "name" => "Test Site",
             "email_address" => "user@example.org",
             "invitation" => "Write to user@example.org or info@example.org",
             "_embedded" => %{"users" => [%{"name_last" => "Test User", "name_middle" => ""}]}
           }
  end

  test "names data.castoredc.com in links, whatever server the fixtures came from" do
    links = %{"_links" => %{"self" => %{"href" => "https://dev.example.test/api/study/1"}}, "count" => 1}

    assert Record.public_server(links, "https://dev.example.test/") ==
             %{"_links" => %{"self" => %{"href" => "https://data.castoredc.com/api/study/1"}}, "count" => 1}
  end

  test "refuses to run without the test study's configuration" do
    previous = System.get_env("CASTOR_EDC_STUDY_ID")
    System.delete_env("CASTOR_EDC_STUDY_ID")
    on_exit(fn -> if previous, do: System.put_env("CASTOR_EDC_STUDY_ID", previous) end)

    assert_raise Mix.Error, ~r/isn't set/, fn -> Record.run([]) end
  end
end
