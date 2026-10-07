# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Modules for 93 operations of the API, generated from its corrected spec (`CastorEDC.Participants`, `CastorEDC.DataPoints` and 16 more), with structs for their responses under `CastorEDC.Model`. Paged collections also have `stream_` functions.
- Requests go over HTTP/2, so concurrent requests share one connection; `connect_options: [protocols: [:http1]]` switches back.
- `CastorEDC.new/1` builds a Req-based client from API credentials, the application environment or environment variables.
- Clients built from client credentials fetch, cache and renew access tokens themselves, and retry once with a new token on a 401.
- The client stays within the API's rate limits: when a route's allowance is used up it waits for the window to reset, and a request that still gets a 429 is sent again after the reset. `rate_limit: :error` returns an error instead of waiting.
- `CastorEDC.Client.request/2` runs an operation and returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`; collections come back as a `CastorEDC.Page`.

### Changed

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

[0.4.1]: https://hex.pm/packages/ex_castor_edc/0.4.1
[0.4.0]: https://hex.pm/packages/ex_castor_edc/0.4.0
[0.3.0]: https://hex.pm/packages/ex_castor_edc/0.3.0
[0.2.0]: https://hex.pm/packages/ex_castor_edc/0.2.0
[0.1.0]: https://hex.pm/packages/ex_castor_edc/0.1.0
