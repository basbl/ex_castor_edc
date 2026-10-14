# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-rc.1] - 2026-10-14

A rewrite on [Req](https://hexdocs.pm/req), with a function for every operation of the API; see the migration guide.

### Added

- Modules for the API's 92 operations, generated from its corrected spec (`CastorEDC.Participants`, `CastorEDC.DataPoints` and 16 more), with structs for their responses under `CastorEDC.Model`.
  Paged collections also have `stream_` functions.
  The API's times without a zone decode to `NaiveDateTime`s in the server's time.
- `CastorEDC.new/1` builds a client from API credentials and a server, given as options, in the application environment or in environment variables (`CASTOR_EDC_CLIENT_ID`, `CASTOR_EDC_CLIENT_SECRET`, `CASTOR_EDC_BASE_URL`).
  Requests go over HTTP/2; `connect_options: [protocols: [:http1]]` switches back.
  A client's inspect output hides its client secret.
- Clients built from client credentials fetch, cache and renew access tokens themselves, and retry once with a new token on a 401.
- `CastorEDC.time_zone/1`, the time zone of a client's server, which the API's times without a zone are local to.
  The public servers' zones are built in; the `:time_zone` option (or `CASTOR_EDC_TIME_ZONE`) sets it for a private server.
- The client stays within the API's rate limits: when a route's allowance is used up it waits for the window to reset, and a request that still gets a 429 is sent again after the reset.
  `rate_limit: :error` returns an error instead of waiting, and `:max_rate_limit_wait` caps the wait.
- `CastorEDC.Error` describes a failed request, whichever kind of error body the API sent, with the `request_id` Castor support can trace.
- Bulk writes (data points, sites and repeating data instances) return what was `saved` and what `failed`, as the API answers 201 even when some fail; their `!` variants raise a `CastorEDC.Error` with `code: :not_saved` when anything failed.
  The repeating data, survey and survey package instance writes fill in the `instance_id` each value needs from the instance in the path.
- Uploading a file as a data point's value: `create_study_data_point`, `create_survey_data_point` and `create_repeating_data_data_point` take `"upload_file" => {file name, contents}` (or a `File.Stream`) in the body, sent as multipart form data.
- `CastorEDC.Export` runs batch exports in one call per type (`participant_data/3`, `sites/3` and nine more): it checks the format, filters and options, queues the export, waits until it is ready and downloads it, in memory or to disk, unzipped if asked.
  While three exports are running it waits for a slot.
  The steps are public too, and each emits telemetry.
- `CastorEDC.FieldValue.decode/2` turns the strings the API sends as data point values into Elixir values by field type, with `CastorEDC.MissingValue` for values marked missing and `CastorEDC.PartialDate` for dates with unknown parts.
  Grids decode cell by cell by the grid's layout, and uploads, locations and encrypted values decode too.
  `CastorEDC.FieldValue.label/2` gives the names of chosen options.
- `CastorEDC.Tabular.schema/2` describes a study's fields for tables, and `CastorEDC.Tabular.data_points/3` streams every value the study collected, decoded, one row per value, or with `format: :wide` one row per participant or instance with a column per variable.
- `CastorEDC.Test` builds clients whose responses a test writes, for testing code that uses the library without a network.
- A guide to migrating from 0.4, and a Livebook notebook to get started.

### Changed

- **Breaking:** `CastorEDC.authenticate/1` and `CastorEDC.Legacy.Client` are gone, and with them Tesla and Hackney: build a client with `CastorEDC.new/1`, which fetches and renews tokens itself.
- **Breaking:** the remaining modules under `CastorEDC.DataCollection` are replaced by generated ones: `Queries` by `CastorEDC.Queries` (`list_queries`, `get_query`), `RepeatingDataInstances` by `CastorEDC.RepeatingData` (`list_repeating_data_instances`, `get_repeating_data_instance`), `Statistics.find` by `CastorEDC.Studies.get_study_statistics/3`, `SurveyPackageInstances` by `CastorEDC.Surveys` (`list_survey_package_instances`, `get_survey_package_instance`, `create_survey_package_instance`, `update_survey_package_instance`), and `Verifications` by `CastorEDC.Verifications.list_verifications/3`.
- **Breaking:** the data point modules under `CastorEDC.DataCollection.DataEntry` and `CastorEDC.DataCollection.DataPoints` are replaced by `CastorEDC.DataPoints`: single data points by `get_study_data_point`, `create_study_data_point`, `get_survey_data_point`, `create_survey_data_point`, `get_repeating_data_data_point` and `create_repeating_data_data_point`; collections by `list_study_data_points`, `list_survey_data_points`, `list_repeating_data_data_points` and their per-instance and per-participant variants; bulk writes by `upsert_study_data_points` and its survey and repeating data variants, which return what was saved and what wasn't.
- **Breaking:** the participant modules under `CastorEDC.DataCollection` are replaced by generated ones: `Participants` by `CastorEDC.Participants` (`list_participants`, `get_participant`, `create_participant`), `Participants.Progress` by `CastorEDC.Participants.list_form_progress/3`, `Participants.RepeatingDataInstances` by `CastorEDC.RepeatingData` (`list_participant_repeating_data_instances`, `get_participant_repeating_data_instance`, `create_repeating_data_instance`, `create_repeating_data_instances`), and `Randomization` by `CastorEDC.Randomization` (`get_randomization`, `randomize_participant`).
  `Participants.SurveyPackageInstances.patch` has no replacement: it needs the participant app's scope.
- **Breaking:** the modules under `CastorEDC.StudyProtocol` are replaced by generated ones: fields, field dependencies and field validations by `CastorEDC.Fields` (`list_fields`, `get_field`, `list_field_dependencies`, `get_field_dependency`, `list_field_validations`, `get_field_validation`); forms and visits by `CastorEDC.Forms` (`list_forms`, `get_form`, `list_visits`, `get_visit`); metadata and metadata types by `CastorEDC.Metadata`; option groups by `CastorEDC.OptionGroups`; repeating data and its forms by `CastorEDC.RepeatingData`; surveys, survey forms and survey packages by `CastorEDC.Surveys`.
  Every `list/2` becomes `list_<things>` and every `find/3` becomes `get_<thing>`.
- **Breaking:** the modules under `CastorEDC.Common` are replaced by generated ones: `Countries.list/1` and `find/2` become `CastorEDC.Countries.list_countries/2` and `get_country/3`; `Sites` become `CastorEDC.Sites.list_sites`, `get_site` and `create_site`; `Studies` become `CastorEDC.Studies.list_studies` and `get_study`; `Studies.Roles` become `CastorEDC.Roles.list_roles`, `get_role` and `create_role`; `Studies.Users` become `CastorEDC.StudyUsers.list_study_users` and `get_study_user`; `Users` become `CastorEDC.Users.list_users` and `get_user`.
- **Breaking:** Elixir 1.20 or later is required.
- Dependencies are updated to their latest compatible versions, so the library builds on OTP 29.
- JSON is encoded and decoded with Elixir's built-in `JSON` module; the library no longer depends on Jason.

## [0.4.1] - 2023-04-30

### Fixed

- Renames missed in 0.4.0.

## [0.4.0] - 2023-04-26

### Changed

- **Breaking:** module and function names follow the terminology of the Castor EDC API.

## [0.3.0] - 2022-08-25

### Added

- `CastorEDC.Client.new/2` accepts either client credentials or an existing access token.
- The HTTP adapter is configurable, so clients other than Hackney can be used.
- The user agent is configurable.

### Changed

- **Breaking:** errors return `{:error, reason}` instead of raising.
- **Breaking:** the endpoint is an option rather than an optional argument.
- **Breaking:** the `timeout` option is renamed to `global_timeout`.

## [0.2.0] - 2022-05-27

### Added

- Report instance and survey package instance endpoints.
- Creating and updating data point collections.
- File uploads when creating a single data point.

### Changed

- **Breaking:** HTTP requests use Tesla instead of HTTPoison.

## [0.1.0] - 2022-05-18

- Initial release.

[1.0.0-rc.1]: https://hex.pm/packages/ex_castor_edc/1.0.0-rc.1
[0.4.1]: https://hex.pm/packages/ex_castor_edc/0.4.1
[0.4.0]: https://hex.pm/packages/ex_castor_edc/0.4.0
[0.3.0]: https://hex.pm/packages/ex_castor_edc/0.3.0
[0.2.0]: https://hex.pm/packages/ex_castor_edc/0.2.0
[0.1.0]: https://hex.pm/packages/ex_castor_edc/0.1.0
