# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- `CastorEDC.Error` has `export_ids` and `result` for errors the client makes itself, and lists its own codes. The export errors carry the exports' IDs in `export_ids` (an `:export_timeout`'s pending IDs were in `details` as messages) and the export in `result` (it was in `body`), and `:not_saved` the write's result in `result`. `body` and `details` are only ever what the API sent.
- Creating sites and repeating data instances answers like a bulk data point write, and the client now treats it alike: `CastorEDC.Model.SiteCollection` and `RepeatingDataInstanceCollection` list what was created under `saved` (it was `success`), and `create_site!/4` and `create_repeating_data_instances!/5` raise a `CastorEDC.Error` with `code: :not_saved` when anything wasn't, as the data point `!` functions do.
- Lists return the same struct as fetching one record: `list_countries` gives `CastorEDC.Model.Country`s, `list_studies` `CastorEDC.Model.Study`s, and a created site comes back as a `CastorEDC.Model.Site`. `CountryWithNoHalLinks`, `StudyCollectionItem` and `SiteNoLinks`, copies of those with a field or two less, are gone.
- A study's `created_on`, `first_live_on` and `last_datapoint_collected_on` (in `CastorEDC.Model.Study`), and a repeating data instance's `created_on`, are `NaiveDateTime`s in the server's time, as a data point's `updated_on` is, instead of strings.
- `CastorEDC.Client.request/2` and `request!/2`, the operation descriptions they take, the `CastorEDC.Model` decoding helpers and `CastorEDC.RateLimit.lookup/1` are no longer documented: they're how the generated modules work, not public API, and may change in any release.

### Fixed

- A client with the right client ID but another secret no longer reuses a token another client cached: tokens are cached per client ID and a hash of the secret, so a wrong or revoked secret always means asking the API.
- The token request passes on Req's `:plug` option, so a client built for `Req.Test` works, and reads a token lifetime given as text instead of raising.
- Req's own retry no longer runs on top of the rate limit handling: a 429 was retried up to three more times with Req's backoff, so `rate_limit: :error` waited seconds and returned a made-up error instead of the API's 429, and `:wait` sent up to seven requests instead of four. Clients retry what Req's default does, but never a 429.
- A rate limit reset time that isn't a Unix timestamp in seconds no longer crashes every request; and waiting out a 429 adds the same jitter as waiting before a request, so a clock ahead of the server's doesn't retry before the window resets.
- Export date-time filters take a `DateTime` in the server's time (Europe/Amsterdam): one was sent as its own wall clock, so a UTC time was read an hour or two off. They're documented as to the minute, as the API takes them.
- An export saved into a directory keeps the server's file name inside it: a name with directories in it could have put the file, and what was unzipped from it, elsewhere.
- A PHP DateTime with an offset zone (`+02:00`) decodes to a UTC `DateTime` instead of staying a map, and a local time a clock change skips becomes the moment after the gap, as PHP reads it. `CastorEDC.FieldValue.decode/2` takes the field type as an atom too, instead of raising.
- `CastorEDC.Tabular.data_points/3`'s wide format no longer loses values: columns that would share a name (a checkbox `sym` with option `1` and a field `sym_1`) are both named after their field ID, and fields on no form the study knows are the study's own instead of vanishing from the rows.
- A client's client secret no longer shows when the client is inspected, as in a log, an IEx session or a notebook's output.

## [1.0.0-rc.1] - 2026-10-08

### Added

- Modules for 92 operations of the API, generated from its corrected spec (`CastorEDC.Participants`, `CastorEDC.DataPoints` and 16 more), with structs for their responses under `CastorEDC.Model`. Paged collections also have `stream_` functions.
- Requests go over HTTP/2, so concurrent requests share one connection; `connect_options: [protocols: [:http1]]` switches back.
- `CastorEDC.new/1` builds a Req-based client from API credentials and a server, given as options, in the application environment or in environment variables (`CASTOR_EDC_CLIENT_ID`, `CASTOR_EDC_CLIENT_SECRET`, `CASTOR_EDC_BASE_URL`).
- Clients built from client credentials fetch, cache and renew access tokens themselves, and retry once with a new token on a 401.
- The client stays within the API's rate limits: when a route's allowance is used up it waits for the window to reset, and a request that still gets a 429 is sent again after the reset. `rate_limit: :error` returns an error instead of waiting.
- `CastorEDC.Client.request/2` runs an operation and returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`; collections come back as a `CastorEDC.Page`.
- `CastorEDC.DataPoints.upsert_repeating_data_instance_data_points/5` fills in the `instance_id` the API wants in every value from the instance in the path.
- `CastorEDC.Export` runs batch exports in one call per type (`participant_data/3`, `sites/3` and nine more): it queues the export, checking its format, filters and options against the spec and against the rules the API applies beyond it (most participant data options only apply to some formats, grouped or not), waits until it is ready by polling with backoff (15 minutes by default, an hour for PDFs), and downloads it, in memory or streamed to disk, unzipped if asked. While three exports are running it waits for a slot. The steps are public too, and each emits telemetry.
- `CastorEDC.FieldValue.decode/2` turns the strings the API sends as data point values into Elixir values by field type, with `CastorEDC.MissingValue` for values marked missing and `CastorEDC.PartialDate` for dates with unknown parts. Grids, uploads and locations decode too. `CastorEDC.FieldValue.label/2` gives the names of chosen options.
- `CastorEDC.Tabular.schema/2` describes a study's fields for tables: variable names, whether they collect data in the study, a repeating data or a survey, and the type of their values. `CastorEDC.Tabular.data_points/3` streams every value the study collected, decoded, one row per value, or with `format: :wide` one row per participant or instance with a column per variable.
- A guide to migrating from 0.4, with each 0.4 function's replacement.
- `CastorEDC.Test` builds clients whose responses a test writes, for testing code that uses the library without a network.

### Changed

- **Breaking:** `CastorEDC.authenticate/1` and `CastorEDC.Legacy.Client` are gone, and with them Tesla and Hackney: build a client with `CastorEDC.new/1`, which fetches and renews tokens itself.
- **Breaking:** the remaining modules under `CastorEDC.DataCollection` are replaced by generated ones: `Queries` by `CastorEDC.Queries` (`list_queries`, `get_query`), `RepeatingDataInstances` by `CastorEDC.RepeatingData` (`list_repeating_data_instances`, `get_repeating_data_instance`), `Statistics.find` by `CastorEDC.Studies.get_study_statistics`, `SurveyPackageInstances` by `CastorEDC.Surveys` (`list_survey_package_instances`, `get_survey_package_instance`, `create_survey_package_instance`, `update_survey_package_instance`), and `Verifications` by `CastorEDC.Verifications.list_verifications`.
- **Breaking:** the data point modules under `CastorEDC.DataCollection.DataEntry` and `CastorEDC.DataCollection.DataPoints` are replaced by `CastorEDC.DataPoints`: single data points by `get_study_data_point`, `create_study_data_point`, `get_survey_data_point`, `create_survey_data_point`, `get_repeating_data_data_point` and `create_repeating_data_data_point`; collections by `list_study_data_points`, `list_survey_data_points`, `list_repeating_data_data_points` and their per-instance and per-participant variants; bulk writes by `upsert_study_data_points` and its survey and repeating data variants, which return what was saved and what wasn't. Uploading a file with a single data point is no longer supported.
- **Breaking:** the participant modules under `CastorEDC.DataCollection` are replaced by generated ones: `Participants` by `CastorEDC.Participants` (`list_participants`, `get_participant`, `create_participant`), `Participants.Progress` by `CastorEDC.Participants.list_form_progress`, `Participants.RepeatingDataInstances` by `CastorEDC.RepeatingData` (`list_participant_repeating_data_instances`, `get_participant_repeating_data_instance`, `create_repeating_data_instance`, `create_repeating_data_instances`), and `Randomization` by `CastorEDC.Randomization` (`get_randomization`, `randomize_participant`). `Participants.SurveyPackageInstances.patch` has no replacement: it needs the participant app's scope.
- **Breaking:** the modules under `CastorEDC.StudyProtocol` are replaced by generated ones: fields, field dependencies and field validations by `CastorEDC.Fields` (`list_fields`, `get_field`, `list_field_dependencies`, `get_field_dependency`, `list_field_validations`, `get_field_validation`); forms and visits by `CastorEDC.Forms` (`list_forms`, `get_form`, `list_visits`, `get_visit`); metadata and metadata types by `CastorEDC.Metadata`; option groups by `CastorEDC.OptionGroups`; repeating data and its forms by `CastorEDC.RepeatingData`; surveys, survey forms and survey packages by `CastorEDC.Surveys`. Every `list/2` becomes `list_<things>` and every `find/3` becomes `get_<thing>`.
- **Breaking:** the modules under `CastorEDC.Common` are replaced by generated ones: `Countries.list/1` and `find/2` become `CastorEDC.Countries.list_countries/2` and `get_country/3`; `Sites` become `CastorEDC.Sites.list_sites`, `get_site` and `create_site`; `Studies` become `CastorEDC.Studies.list_studies` and `get_study`; `Studies.Roles` become `CastorEDC.Roles.list_roles`, `get_role` and `create_role`; `Studies.Users` become `CastorEDC.StudyUsers.list_study_users` and `get_study_user`; `Users` become `CastorEDC.Users.list_users` and `get_user`.
- **Breaking:** Elixir 1.20 or later is required.
- **Breaking:** `CastorEDC.Client` is renamed to `CastorEDC.Legacy.Client`, making room for the new Req-based client. It goes away in 1.0.
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
