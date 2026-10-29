# ExCastorEDC

[![Package](https://img.shields.io/hexpm/v/ex_castor_edc.svg)](https://hex.pm/packages/ex_castor_edc) [![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_castor_edc) ![CI](https://github.com/basbl/ex_castor_edc/actions/workflows/ci.yml/badge.svg)

An unofficial Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

Every operation of the API has a function, generated from a corrected copy of its spec.
The client takes care of authentication, paging, rate limits and batch exports, and decodes the values a study collected.

Coming from 0.4? See the [migration guide](guides/migrating-to-1.0.md).

## Installation

```elixir
def deps do
  [
    {:ex_castor_edc, "~> 1.0"}
  ]
end
```

It needs Elixir 1.20 or later.

## Usage

Create API credentials on your [account settings page](https://data.castoredc.com/account/settings), and build a client from them:

```elixir
client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")
```

The client fetches and renews its access token itself.
The credentials can also come from the application environment or from `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET`, and `:base_url` picks another server, such as `https://us.castoredc.com`.
The client is a `Req.Request`, so any other option goes to [Req](https://hexdocs.pm/req).

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`, and has a `!` variant that returns the result or raises:

```elixir
{:ok, study} = CastorEDC.Studies.get_study(client, study_id)

participant = CastorEDC.Participants.get_participant!(client, study_id, "110001")
participant.site.name
```

Collections come back as a `CastorEDC.Page`, and paged operations also have a `stream_` function that fetches pages as the stream is consumed:

```elixir
client
|> CastorEDC.Participants.stream_participants(study_id)
|> Enum.reject(& &1.archived)
```

When a route's rate limit is used up, the client waits for it to reset; see `CastorEDC.RateLimit`.

## Exports

`CastorEDC.Export` queues a batch export, waits for it and downloads it, in one call:

```elixir
{:ok, export} =
  CastorEDC.Export.participant_data(client, study_id, into: "exports/", unzip: true)
export.files
```

## Field values

The API sends every value as a string.
`CastorEDC.FieldValue.decode/2` reads it by the field's type, and `CastorEDC.Tabular` streams a study's values as rows, one per value or one per participant:

```elixir
{:ok, schema} = CastorEDC.Tabular.schema(client, study_id)
rows = CastorEDC.Tabular.data_points(client, study_id, schema: schema, format: :wide)
```

## Testing your code

`CastorEDC.Test` builds clients whose responses your test writes, so code that uses the library can be tested without a network.

## Contributing

See [CONTRIBUTING.md](https://github.com/basbl/ex_castor_edc/blob/main/CONTRIBUTING.md).

## License

MIT; see [LICENSE.md](https://github.com/basbl/ex_castor_edc/blob/main/LICENSE.md).
