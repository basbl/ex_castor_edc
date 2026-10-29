# Migrating from 0.4 to 1.0

1.0 is a rewrite.
Every operation of the API has a function now, generated from a corrected copy of the API's spec, and the client runs on [Req](https://hexdocs.pm/req) instead of Tesla.
This guide takes a 0.4 program to 1.0: the client, the shape of results, each function's replacement, and what's new.

## Requirements

1.0 needs Elixir 1.20 or later.
Tesla, Hackney and Jason are no longer dependencies; drop any configuration you had for them.

```elixir
def deps do
  [
    {:ex_castor_edc, "~> 1.0"}
  ]
end
```

## The client

In 0.4, you built a client and then authenticated it:

```elixir
client =
  CastorEDC.Client.new(%{client_id: id, client_secret: secret}, endpoint: "https://us.castoredc.com/")
{:ok, client} = CastorEDC.authenticate(client)
```

In 1.0, `CastorEDC.new/1` builds a client that authenticates itself: it fetches an access token with the first request, renews it before it expires, and retries once with a new token if the API turns one down.

```elixir
client =
  CastorEDC.new(client_id: id, client_secret: secret, base_url: "https://us.castoredc.com")
```

- The credentials and server can also come from the application environment (`config :ex_castor_edc, client_id: ..., client_secret: ..., base_url: ...`) or from the `CASTOR_EDC_CLIENT_ID`, `CASTOR_EDC_CLIENT_SECRET` and `CASTOR_EDC_BASE_URL` environment variables, so `CastorEDC.new()` is often enough.
- `:endpoint` is now `:base_url`, without the trailing slash.
- A long-lived token still works: `CastorEDC.new(access_token: token)`.
- The client is a `Req.Request`, and every option `CastorEDC.new/1` doesn't know goes to Req.
  `:global_timeout` becomes Req's `:receive_timeout`; `:adapter` and `:adapter_options` have no equivalent, because Req uses Finch.
  Requests go over HTTP/2.
- `CastorEDC.authenticate(client)`, `CastorEDC.Client.new(credentials, options)`, `CastorEDC.Client.update_token(client, token)`, and the request helpers `CastorEDC.get(url, client, params)`, `post` and `patch`, are gone.

Every function also accepts the options to build a client with, instead of the client itself: `CastorEDC.Studies.list_studies(client_id: id, client_secret: secret)`.

## Results

0.4 returned the status, the decoded JSON and the Tesla response, and left errors to you:

```elixir
{200, %{"_embedded" => %{"participants" => participants}}, _response} =
  CastorEDC.DataCollection.Participants.list(client, study_id)
```

1.0 returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`, and each function has a `!` variant that returns the result or raises:

```elixir
{:ok, %CastorEDC.Page{entries: participants}} =
  CastorEDC.Participants.list_participants(client, study_id)
participants = CastorEDC.Participants.list_participants!(client, study_id).entries
```

- A single record is a struct under `CastorEDC.Model`, such as `CastorEDC.Model.Participant`, with snake_case fields and the current terminology: visits rather than phases, forms rather than steps, repeating data rather than reports.
  Dates and times are `DateTime`s, and `NaiveDateTime`s in the server's time where the API gives no zone (see `CastorEDC.time_zone/1`).
  Fields the spec doesn't describe are kept in `extra`.
- A collection is a `CastorEDC.Page`, with `entries`, `page`, `page_count`, `page_size` and `total_items`, whatever envelope the API used.
  An empty collection is an empty page, also where the API answers 404 for a participant without repeating data instances.
- A bulk data point write returns a `CastorEDC.Model.DataPointsResult` with what was `saved` and what `failed`, because the API answers 201 even when values fail.
  The `!` variant raises when anything failed.
- A failed request is a `CastorEDC.Error`, with the HTTP `status` (or `nil` and a `reason` when no answer came), the API's `message`, `code` and `details`, and the `request_id` Castor support can trace.

## Query parameters

0.4 took query parameters as a keyword list of the API's names.
In 1.0 they're options with snake_case names, listed in each function's docs, and any other option goes to Req:

```elixir
CastorEDC.DataCollection.Participants.list(client, study_id, page: 2)
CastorEDC.Participants.list_participants(client, study_id, page: 2, page_size: 100)
```

Path parameters have consistent names too: `field_dependency_id`, `option_group_id`, `repeating_data_instance_id`.

## Paging and streaming

Paged operations have a `stream_` function that fetches the pages as the stream is consumed, at the largest page size the API allows:

```elixir
client
|> CastorEDC.Participants.stream_participants(study_id)
|> Enum.filter(& &1.locked)
```

## Rate limits

0.4 left rate limits to you.
1.0 reads the API's rate limit headers, waits when a route's allowance is used up, and sends a request that still gets a 429 again once the window resets.
`rate_limit: :error` returns the 429 as an error instead, and `:max_rate_limit_wait` caps the wait.
See `CastorEDC.RateLimit`.

## Exports

0.4 had no exports.
1.0 runs the API's batch exports in one call per type, which queues the export, waits for it and downloads it:

```elixir
{:ok, export} =
  CastorEDC.Export.participant_data(client, study_id, into: "exports/", unzip: true)
export.files
```

The formats, filters and options of each type are checked before anything is sent; see `CastorEDC.Export`.
The API's synchronous CSV exports are deprecated, and 1.0 doesn't offer them.

## Field values

The API sends every value as a string.
`CastorEDC.FieldValue.decode/2` turns them into Elixir values by field type, with `CastorEDC.MissingValue` for values marked missing and `CastorEDC.PartialDate` for dates with unknown parts, and `CastorEDC.Tabular` turns a study's values into rows for a dataframe library.

## Function by function

Every 0.4 function has a 1.0 replacement, apart from `SurveyPackageInstances.patch/5`.
`list` and `find` become `list_<things>` and `get_<thing>`; arguments keep their order.

| 0.4 | 1.0 |
| --- | --- |
| `Common.Countries.list/1`, `find/2` | `CastorEDC.Countries.list_countries/2`, `get_country/3` |
| `Common.Users.list/1`, `find/2` | `CastorEDC.Users.list_users/2`, `get_user/3` |
| `Common.Studies.list/1`, `find/2` | `CastorEDC.Studies.list_studies/2`, `get_study/3` |
| `Common.Studies.Users.list/2`, `find/3` | `CastorEDC.StudyUsers.list_study_users/3`, `get_study_user/4` |
| `Common.Studies.Roles.list/2`, `find/3`, `create/3` | `CastorEDC.Roles.list_roles/3`, `get_role/4`, `create_role/4` |
| `Common.Sites.list/3`, `find/4`, `create/3` | `CastorEDC.Sites.list_sites/3`, `get_site/4`, `create_site/4` |
| `DataCollection.Participants.list/3`, `find/3`, `create/3` | `CastorEDC.Participants.list_participants/3`, `get_participant/4`, `create_participant/4` |
| `DataCollection.Participants.Progress.list/3` | `CastorEDC.Participants.list_form_progress/3` |
| `DataCollection.Participants.RepeatingDataInstances.list/4`, `find/4` | `CastorEDC.RepeatingData.list_participant_repeating_data_instances/4`, `get_participant_repeating_data_instance/5` |
| `DataCollection.Participants.RepeatingDataInstances.create/4` | `CastorEDC.RepeatingData.create_repeating_data_instance/5`, or `create_repeating_data_instances/5` for a list |
| `DataCollection.Randomization.find/3`, `create/3` | `CastorEDC.Randomization.get_randomization/4`, `randomize_participant/4` |
| `DataCollection.RepeatingDataInstances.list/3`, `find/3` | `CastorEDC.RepeatingData.list_repeating_data_instances/3`, `get_repeating_data_instance/4` |
| `DataCollection.Statistics.find/2` | `CastorEDC.Studies.get_study_statistics/3` |
| `DataCollection.SurveyPackageInstances.list/3`, `find/3` | `CastorEDC.Surveys.list_survey_package_instances/3`, `get_survey_package_instance/4` |
| `DataCollection.SurveyPackageInstances.create/3`, `patch/4` | `CastorEDC.Surveys.create_survey_package_instance/4`, `update_survey_package_instance/5` |
| `DataCollection.Queries.list/3`, `find/4` | `CastorEDC.Queries.list_queries/3`, `get_query/4` |
| `DataCollection.Verifications.list/3` | `CastorEDC.Verifications.list_verifications/3` |
| `DataCollection.DataEntry.StudyDataPoint.list/4` | `CastorEDC.DataPoints.list_participant_study_data_points/4` |
| `DataCollection.DataEntry.StudyDataPoint.find/5`, `create/5` | `CastorEDC.DataPoints.get_study_data_point/5`, `create_study_data_point/6` |
| `DataCollection.DataEntry.SurveyDataPoint.list/5` | `CastorEDC.DataPoints.list_participant_survey_instance_data_points/5` |
| `DataCollection.DataEntry.SurveyDataPoint.find/6`, `create/6` | `CastorEDC.DataPoints.get_survey_data_point/6`, `create_survey_data_point/7` |
| `DataCollection.DataEntry.RepeatingDataDataPoint.list/5` | `CastorEDC.DataPoints.list_participant_repeating_data_instance_data_points/5` |
| `DataCollection.DataEntry.RepeatingDataDataPoint.find/6`, `create/6` | `CastorEDC.DataPoints.get_repeating_data_data_point/6`, `create_repeating_data_data_point/7` |
| `DataCollection.DataPoints.StudyDataPointCollection.list/3`, `create/4` | `CastorEDC.DataPoints.list_study_data_points/3`, `upsert_study_data_points/5` |
| `DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.list/3`, `find/4`, `create/5` | `CastorEDC.DataPoints.list_repeating_data_data_points/3`, `list_repeating_data_instance_data_points/4`, `upsert_repeating_data_instance_data_points/6` |
| `DataCollection.DataPoints.SurveyInstanceDataPointCollection.list/3`, `find/4`, `create/5` | `CastorEDC.DataPoints.list_survey_data_points/3`, `list_survey_instance_data_points/4`, `upsert_survey_instance_data_points/6` |
| `DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.list/4`, `create/5` | `CastorEDC.DataPoints.list_survey_package_instance_data_points/4`, `upsert_survey_package_instance_data_points/6` |
| `StudyProtocol.Fields.list/3`, `find/4` | `CastorEDC.Fields.list_fields/3`, `get_field/4` |
| `StudyProtocol.FieldDependencies.list/3`, `find/4` | `CastorEDC.Fields.list_field_dependencies/3`, `get_field_dependency/4` |
| `StudyProtocol.FieldValidations.list/3`, `find/4` | `CastorEDC.Fields.list_field_validations/3`, `get_field_validation/4` |
| `StudyProtocol.Forms.list/3`, `find/4` | `CastorEDC.Forms.list_forms/3`, `get_form/4` |
| `StudyProtocol.Visits.list/3`, `find/4` | `CastorEDC.Forms.list_visits/3`, `get_visit/4` |
| `StudyProtocol.Metadata.list/3`, `find/4` | `CastorEDC.Metadata.list_metadata/3`, `get_metadata/4` |
| `StudyProtocol.MetadataTypes.list/3`, `find/4` | `CastorEDC.Metadata.list_metadata_types/3`, `get_metadata_type/4` |
| `StudyProtocol.OptionGroups.list/3`, `find/4` | `CastorEDC.OptionGroups.list_option_groups/3`, `get_option_group/4` |
| `StudyProtocol.RepeatingData.list/3`, `find/3` | `CastorEDC.RepeatingData.list_repeating_data/3`, `get_repeating_data/4` |
| `StudyProtocol.RepeatingDataForms.list/4`, `find/5` | `CastorEDC.RepeatingData.list_repeating_data_forms/4`, `get_repeating_data_form/5` |
| `StudyProtocol.Surveys.list/3`, `find/3` | `CastorEDC.Surveys.list_surveys/3`, `get_survey/4` |
| `StudyProtocol.SurveyForms.list/4`, `find/5` | `CastorEDC.Surveys.list_survey_forms/4`, `get_survey_form/5` |
| `StudyProtocol.SurveyPackages.list/3`, `find/3` | `CastorEDC.Surveys.list_survey_packages/3`, `get_survey_package/4` |
| `DataCollection.Participants.SurveyPackageInstances.patch/5` | none: the endpoint needs the participant app's scope |
| `create` of `DataCollection.DataEntry.StudyDataPoint`, `SurveyDataPoint` or `RepeatingDataDataPoint` with an `"upload_file"` | `CastorEDC.DataPoints.create_study_data_point/6`, `create_survey_data_point/7` or `create_repeating_data_data_point/7` with `"upload_file" => {file name, contents}` in the body, sent as multipart form data |

Every 1.0 function takes options last, so its arity is one more than its arguments; the table counts them.

## New in 1.0

Besides exports and field values, 1.0 covers what 0.4 didn't: study users can be added, updated and removed (`CastorEDC.StudyUsers`), participant progress per visit and per repeating data (`CastorEDC.Participants`), survey compliance (`CastorEDC.Surveys.list_survey_compliance/3`), and survey package instances created with their data points (`CastorEDC.DataPoints.create_survey_package_instance_with_data_points/5`).
`CastorEDC.Test` builds clients for testing code that uses the library, without a network.
The modules' docs list every operation.
