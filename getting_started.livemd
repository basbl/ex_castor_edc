# Using the Castor EDC API

```elixir
# The published version, or the checkout CASTOR_EDC_PATH names.
castor_edc =
  case System.get_env("CASTOR_EDC_PATH") do
    nil -> {:ex_castor_edc, "~> 1.0"}
    path -> {:ex_castor_edc, path: path}
  end

Mix.install([
  castor_edc,
  {:kino, "~> 0.19"}
])
```

## Introduction

This notebook introduces the library. It isn't an exhaustive guide: the documentation lists every operation.

## Connecting

You need a client ID and a client secret, which you can create on your [account settings page](https://data.castoredc.com/account/settings).
Enter them below, together with the region your studies are in, after evaluating the code block.

```elixir
regions = [
  {"https://data.castoredc.com", "NL"},
  {"https://uk.castoredc.com", "UK"},
  {"https://us.castoredc.com", "US"},
  {"https://au.castoredc.com", "AU"}
]

region = Kino.Input.select("Region", regions) |> Kino.render()
client_id = Kino.Input.text("Client ID") |> Kino.render()
client_secret = Kino.Input.password("Client secret") |> Kino.render()

Kino.nothing()
```

`CastorEDC.new/1` builds a client from them.
It doesn't contact the API yet: the client fetches an access token with the first request, and renews it when it expires.

```elixir
client =
  CastorEDC.new(
    client_id: Kino.Input.read(client_id),
    client_secret: Kino.Input.read(client_secret),
    base_url: Kino.Input.read(region)
  )
```

## Making requests

Every operation takes the client first and returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`.
Each also has a `!` variant that returns the result directly and raises the error instead, which keeps a notebook short.

Collections come back as a `CastorEDC.Page`, with the records in `entries`.
Let's list the studies your credentials have access to.

```elixir
%CastorEDC.Page{entries: studies} = CastorEDC.Studies.list_studies!(client)

studies
```

Responses are decoded into structs, such as `CastorEDC.Model.Study` here.
Pick a study to look into.

```elixir
study_options =
  studies
  |> Enum.map(&{&1.study_id, &1.name})
  |> Enum.sort_by(&elem(&1, 1))

study_input = Kino.Input.select("Study", study_options)
```

```elixir
study_id = Kino.Input.read(study_input)
```

## Sites

A study is conducted at one or more sites.
Choose a test site: some of the requests below write data, and that data shouldn't end up where it doesn't belong.

```elixir
site_options =
  client
  |> CastorEDC.Sites.list_sites!(study_id)
  |> Map.fetch!(:entries)
  |> Enum.reject(& &1.deleted)
  |> Enum.map(&{&1.id, &1.name})

site_input = Kino.Input.select("Test site", site_options)
```

```elixir
site_id = Kino.Input.read(site_input)
```

## Participants

`CastorEDC.Participants` lists, reads and creates participants.
Options such as `page_size` are passed as a keyword list.

```elixir
%CastorEDC.Page{entries: participants, total_items: total} =
  CastorEDC.Participants.list_participants!(client, study_id, page_size: 10)

IO.puts("#{length(participants)} of #{total} participants")

participants
```

A single participant has more detail, such as their site.

```elixir
[first | _rest] = participants

CastorEDC.Participants.get_participant!(client, study_id, first.participant_id)
```

You can also enrol participants through the API.

**Before you evaluate the code block below, double-check the selected site: you need permission to create participants there.**

```elixir
CastorEDC.Participants.create_participant!(client, study_id, %{"site_id" => site_id})
```

<!-- livebook:{"branch_parent_index":2} -->

## Study structure

A study's visits group its forms, and its forms hold its fields.

```elixir
client
|> CastorEDC.Forms.stream_visits(study_id)
|> Enum.sort_by(& &1.visit_order)
```

```elixir
client
|> CastorEDC.Forms.stream_forms(study_id)
|> Enum.sort_by(& &1.form_order)
```

Functions starting with `stream_` walk every page of a collection, fetching pages only as the stream is consumed.
Here they fetch all fields, including the option groups of radio, dropdown and checkbox fields.

```elixir
fields =
  client
  |> CastorEDC.Fields.stream_fields(study_id, include: "optiongroup")
  |> Enum.to_list()

Enum.frequencies_by(fields, & &1.field_type)
```

<!-- livebook:{"branch_parent_index":2} -->

## Collected data

The study's data points are a paged collection too.
Values arrive as strings, whatever the field's type.

```elixir
client
|> CastorEDC.DataPoints.stream_study_data_points(study_id)
|> Enum.take(10)
```

To fetch only some fields, pass their IDs, such as those of the first three numeric fields:

```elixir
field_ids =
  client
  |> CastorEDC.Fields.stream_fields(study_id)
  |> Stream.filter(&(&1.field_type == "numeric"))
  |> Enum.take(3)
  |> Enum.map(& &1.id)

client
|> CastorEDC.DataPoints.stream_study_data_points(study_id, field_ids: field_ids)
|> Enum.take(10)
```

## Errors

A request the API refuses returns a `CastorEDC.Error` with the status, a message and, when the API gives them, an error code and a request ID that Castor support can trace.

```elixir
CastorEDC.Participants.get_participant(client, study_id, "no-such-participant")
```

The client stays within the API's rate limits by itself: when a route's allowance is used up, it waits for the window to reset.
Pass `rate_limit: :error` to `CastorEDC.new/1` to get an error instead.

## Wrapping up

This notebook gave a taste of how the library works.
The documentation lists every operation, grouped by module: `CastorEDC.Participants`, `CastorEDC.DataPoints`, `CastorEDC.Surveys` and the rest.
