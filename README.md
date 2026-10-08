# ExCastorEDC

[![Package](https://img.shields.io/hexpm/v/ex_castor_edc.svg)](https://hex.pm/packages/ex_castor_edc) [![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_castor_edc) ![CI](https://github.com/basbl/ex_castor_edc/actions/workflows/ci.yml/badge.svg)

An unofficial Elixir client for the [Castor EDC API](https://data.castoredc.com/api).

It covers all 92 public operations of the API, with a function each, generated from a corrected copy of the API's spec, and adds what the API leaves to its clients: authentication, paging, rate limits, batch exports, and decoding the values a study collected.

Coming from 0.4? See the [migration guide](guides/migrating-to-1.0.md).

## Installation

```elixir
def deps do
  [
    {:ex_castor_edc, "~> 1.0"}
  ]
end
```

Or, in a script or Livebook:

```elixir
Mix.install([{:ex_castor_edc, "~> 1.0"}])
```

It needs Elixir 1.20 or later.

## Usage

Build a client from your API credentials, which you create on your [account settings page](https://data.castoredc.com/account/settings):

```elixir
client = CastorEDC.new(client_id: "<client id>", client_secret: "<client secret>")
```

The client fetches an access token with the first request and renews it as it expires. The credentials can also come from the application environment or the `CASTOR_EDC_CLIENT_ID` and `CASTOR_EDC_CLIENT_SECRET` environment variables, and `:base_url` (or `CASTOR_EDC_BASE_URL`) picks another server, such as `https://us.castoredc.com`. The client is a `Req.Request`: any other option goes to [Req](https://hexdocs.pm/req), and requests go over HTTP/2.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`, and has a `!` variant that returns the result or raises:

```elixir
{:ok, study} = CastorEDC.Studies.get_study(client, study_id)
study.name

participant = CastorEDC.Participants.get_participant!(client, study_id, "110001")
participant.site.name
```

Records come back as structs under `CastorEDC.Model`, with snake_case fields and current terminology: visits, forms and repeating data, where the API sometimes says phases, steps and reports.

## Paging

Collections come back as a `CastorEDC.Page`, whatever envelope the API used:

```elixir
{:ok, %CastorEDC.Page{entries: participants, page_count: pages}} =
  CastorEDC.Participants.list_participants(client, study_id, page: 1, page_size: 100)
```

Paged operations also have a `stream_` function, which fetches the pages as the stream is consumed, as large as the API allows:

```elixir
client
|> CastorEDC.Participants.stream_participants(study_id)
|> Enum.reject(& &1.archived)
```

## Rate limits

The API limits how many requests each route takes in a window. The client reads its rate limit headers, waits when a route's allowance is used up, and sends a request that still gets a 429 again once the window resets. `rate_limit: :error` returns the 429 as an error instead, and `:max_rate_limit_wait` caps the wait. See `CastorEDC.RateLimit`.

## Errors

A `CastorEDC.Error` says what went wrong, whichever kind of error body the API sent: the HTTP `status` (or `nil` and the `reason` when no answer came), a `message`, the API's `code` and `details`, and the `request_id` Castor support can trace. Bulk data point writes answer 201 even when values fail; they return what was `saved` and what `failed`, and their `!` variants raise when anything failed.

## Exports

`CastorEDC.Export` runs the API's batch exports in one call per type: it queues the export, checking its format, filters and options first, waits for it to be ready, and downloads it, in memory or to disk, unzipped if you like:

```elixir
{:ok, export} =
  CastorEDC.Export.participant_data(client, study_id,
    filters: [site_ids: [site_id]],
    into: "exports/",
    unzip: true
  )

export.files
```

The steps are public too, so you can queue now and collect later.

## Field values

The API sends every value as a string. `CastorEDC.FieldValue.decode/2` reads it by the field's type, with `CastorEDC.MissingValue` for values marked missing and `CastorEDC.PartialDate` for dates with unknown parts. `CastorEDC.Tabular` describes a study's fields and streams its values as rows, long or wide:

```elixir
{:ok, schema} = CastorEDC.Tabular.schema(client, study_id)

client
|> CastorEDC.Tabular.data_points(study_id, format: :wide, schema: schema)
|> Enum.take(1)
```

For analysis, [ex_castor_edc_explorer](https://github.com/basbl/ex_castor_edc_explorer) and [ex_castor_edc_dux](https://github.com/basbl/ex_castor_edc_dux) turn a study into [Explorer](https://hexdocs.pm/explorer) and [Dux](https://hexdocs.pm/dux) dataframes, and [ex_castor_edc_odm](https://github.com/basbl/ex_castor_edc_odm) into a CDISC ODM v2.0 document.

## Testing your code

`CastorEDC.Test` builds clients whose responses your test writes, so code that uses the library can be tested without a network.

## How it's built

The API's published spec describes it only partly, and sometimes wrongly. `priv/openapi/upstream.json` is that spec as published; `priv/openapi/overlay.yaml` corrects it (names, schemas, paging, error bodies, and what the API really does), and `mix castor_edc.spec.build` applies it to give `priv/openapi/castor_edc.json`. `mix castor_edc.gen.client` generates the endpoint modules and response structs from that, on a small handwritten core: `CastorEDC.Client`, `CastorEDC.Auth`, `CastorEDC.RateLimit`, `CastorEDC.Pagination` and `CastorEDC.Error`. A weekly workflow fetches the published spec and opens an issue when it drifts.

## Development

See [CONTRIBUTING.md](https://github.com/basbl/ex_castor_edc/blob/main/CONTRIBUTING.md) for the setup, the checks every commit passes (`mix precommit` and `mix quality`), the end-to-end tests against a test study, and how commits are made.

## Endpoints

Every operation, by module. `…` stands for `/study/{study_id}`, and the paths are the API's. Paged operations also have a `stream_` function, and every operation a `!` variant.

| Module | Function | Request |
| --- | --- | --- |
| `Countries` | `get_country` | `GET /country/{country_id}` |
|  | `list_countries` | `GET /country` |
| `DataPoints` | `create_repeating_data_data_point` | `POST …/participant/{participant_id}/data-point/repeating-data/{repeating_data_instance_id}/{field_id}` |
|  | `create_study_data_point` | `POST …/participant/{participant_id}/study-data-point/{field_id}` |
|  | `create_survey_data_point` | `POST …/participant/{participant_id}/data-point/survey/{survey_instance_id}/{field_id}` |
|  | `create_survey_package_instance_with_data_points` | `POST …/participant/{participant_id}/data-points/survey-package-instance` |
|  | `get_repeating_data_data_point` | `GET …/participant/{participant_id}/data-point/repeating-data/{repeating_data_instance_id}/{field_id}` |
|  | `get_study_data_point` | `GET …/participant/{participant_id}/study-data-point/{field_id}` |
|  | `get_survey_data_point` | `GET …/participant/{participant_id}/data-point/survey/{survey_instance_id}/{field_id}` |
|  | `list_participant_repeating_data_data_points` | `GET …/participant/{participant_id}/data-points/repeating-data-instance` |
|  | `list_participant_repeating_data_instance_data_points` | `GET …/participant/{participant_id}/data-points/repeating-data-instance/{repeating_data_instance_id}` |
|  | `list_participant_study_data_points` | `GET …/participant/{participant_id}/data-points/study` |
|  | `list_participant_survey_data_points` | `GET …/participant/{participant_id}/data-points/survey-instance` |
|  | `list_participant_survey_instance_data_points` | `GET …/participant/{participant_id}/data-points/survey-instance/{survey_instance_id}` |
|  | `list_participant_survey_package_instance_data_points` | `GET …/participant/{participant_id}/data-points/survey-package-instance/{survey_package_instance_id}` |
|  | `list_repeating_data_data_points` | `GET …/data-points/repeating-data-instance` |
|  | `list_repeating_data_instance_data_points` | `GET …/data-points/repeating-data-instance/{repeating_data_instance_id}` |
|  | `list_study_data_points` | `GET …/data-points/study` |
|  | `list_survey_data_points` | `GET …/data-points/survey-instance` |
|  | `list_survey_instance_data_points` | `GET …/data-points/survey-instance/{survey_instance_id}` |
|  | `list_survey_package_instance_data_points` | `GET …/data-points/survey-package-instance/{survey_package_instance_id}` |
|  | `upsert_repeating_data_instance_data_points` | `POST …/participant/{participant_id}/data-points/repeating-data-instance/{repeating_data_instance_id}` |
|  | `upsert_study_data_points` | `POST …/participant/{participant_id}/data-points/study` |
|  | `upsert_survey_instance_data_points` | `POST …/participant/{participant_id}/data-points/survey-instance/{survey_instance_id}` |
|  | `upsert_survey_package_instance_data_points` | `POST …/participant/{participant_id}/data-points/survey-package-instance/{survey_package_instance_id}` |
| `Exports` | `download_export` | `GET …/export/{id}/download` |
|  | `list_exports` | `GET …/export` |
|  | `queue_exports` | `POST …/export` |
| `Fields` | `get_field` | `GET …/field/{field_id}` |
|  | `get_field_dependency` | `GET …/field-dependency/{fieldDependency_id}` |
|  | `get_field_validation` | `GET …/field-validation/{fieldValidation_id}` |
|  | `list_field_dependencies` | `GET …/field-dependency` |
|  | `list_field_validations` | `GET …/field-validation` |
|  | `list_fields` | `GET …/field` |
| `Forms` | `get_form` | `GET …/form/{form_id}` |
|  | `get_visit` | `GET …/visit/{visit_id}` |
|  | `list_forms` | `GET …/form` |
|  | `list_visits` | `GET …/visit` |
| `Metadata` | `get_metadata` | `GET …/metadata/{metadata_id}` |
|  | `get_metadata_type` | `GET …/metadatatype/{metadatatype_id}` |
|  | `list_metadata` | `GET …/metadata` |
|  | `list_metadata_types` | `GET …/metadatatype` |
| `OptionGroups` | `get_option_group` | `GET …/field-optiongroup/{optiongroup_id}` |
|  | `list_option_groups` | `GET …/field-optiongroup` |
| `Participants` | `create_participant` | `POST …/participant` |
|  | `get_participant` | `GET …/participant/{participant_id}` |
|  | `list_form_progress` | `GET …/participant-progress/forms` |
|  | `list_participants` | `GET …/participant` |
|  | `list_repeating_data_progress` | `GET …/participant-progress/{participant_id}/repeating-data` |
|  | `list_visit_progress` | `GET …/participant-progress/{participant_id}/visit` |
| `Queries` | `get_query` | `GET …/query/{query_id}` |
|  | `list_queries` | `GET …/query` |
| `Randomization` | `get_randomization` | `GET …/participant/{participant_id}/randomization` |
|  | `randomize_participant` | `POST …/participant/{participant_id}/randomization` |
| `RepeatingData` | `create_repeating_data_instance` | `POST …/participant/{participant_id}/repeating-data-instance` |
|  | `create_repeating_data_instances` | `POST …/participant/{participant_id}/repeating-data-instance-collection` |
|  | `get_participant_repeating_data_instance` | `GET …/participant/{participant_id}/repeating-data-instance/{repeating_data_instance_id}` |
|  | `get_repeating_data` | `GET …/repeating-data/{repeating_data_id}` |
|  | `get_repeating_data_form` | `GET …/repeating-data/{repeating_data_id}/repeating-data-form/{repeating_data_form_id}` |
|  | `get_repeating_data_instance` | `GET …/repeating-data-instance/{repeating_data_instance_id}` |
|  | `list_participant_repeating_data_instances` | `GET …/participant/{participant_id}/repeating-data-instance` |
|  | `list_repeating_data` | `GET …/repeating-data` |
|  | `list_repeating_data_forms` | `GET …/repeating-data/{repeating_data_id}/repeating-data-form` |
|  | `list_repeating_data_instances` | `GET …/repeating-data-instance` |
| `Roles` | `create_role` | `POST …/role` |
|  | `get_role` | `GET …/role/{role_name}` |
|  | `list_roles` | `GET …/role` |
| `Sites` | `create_site` | `POST …/site` |
|  | `get_site` | `GET …/site/{site_id}` |
|  | `list_sites` | `GET …/site` |
| `Studies` | `get_study` | `GET /study/{study_id}` |
|  | `get_study_statistics` | `GET …/statistics` |
|  | `list_studies` | `GET /study` |
| `StudyUsers` | `add_study_user` | `POST …/user` |
|  | `get_study_user` | `GET …/user/{user_id}` |
|  | `list_study_users` | `GET …/user` |
|  | `remove_study_user` | `DELETE …/user/{user_id}` |
|  | `update_study_user` | `PUT …/user/{user_id}` |
| `Surveys` | `create_survey_package_instance` | `POST …/survey-package-instance` |
|  | `get_survey` | `GET …/survey/{survey_id}` |
|  | `get_survey_form` | `GET …/survey/{survey_id}/survey-form/{survey_form_id}` |
|  | `get_survey_package` | `GET …/survey-package/{survey_package_id}` |
|  | `get_survey_package_instance` | `GET …/survey-package-instance/{survey_package_instance_id}` |
|  | `list_survey_compliance` | `POST …/compliance` |
|  | `list_survey_forms` | `GET …/survey/{survey_id}/survey-form` |
|  | `list_survey_package_instances` | `GET …/survey-package-instance` |
|  | `list_survey_packages` | `GET …/survey-package` |
|  | `list_surveys` | `GET …/survey` |
|  | `update_survey_package_instance` | `PATCH …/survey-package-instance/{survey_package_instance_id}` |
| `Users` | `get_user` | `GET /user/{user_id}` |
|  | `list_users` | `GET /user` |
| `Verifications` | `list_verifications` | `GET …/verification` |

## License

MIT; see [LICENSE.md](https://github.com/basbl/ex_castor_edc/blob/main/LICENSE.md).
