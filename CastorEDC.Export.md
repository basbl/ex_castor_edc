# `CastorEDC.Export`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/export.ex#L1)

Batch exports: a study's data, structure, queries and more, as files.

The API runs an export as a background job. You queue it, wait until it's
ready, and download the result, which is always a zip. This module does
each of those steps on top of `CastorEDC.Exports`.

There's a function for each type of export that does all three, such as
`participant_data/3`:

    {:ok, %CastorEDC.Export{path: path}} =
      CastorEDC.Export.participant_data(client, study_id,
        format: :spss,
        filters: [site_ids: [site_id]],
        options: [include_comments: true],
        into: "exports/"
      )

The steps are functions too, for queuing several exports at once or
picking up later: `queue/4` queues exports, `await/4` waits until they're
ready, `status/3` looks one up, and `download/4` downloads a ready one.

## Waiting

The API has no way to wait for an export, so `await/4` polls the export
list: after 1 second, then each time half as long again, up to every 15
seconds. One poll covers every export being waited for. The polls go
through `CastorEDC.Client` like any other request, so they count against
the rate limit and appear in its telemetry.

## Telemetry

  * `[:castor_edc, :export, :queued]` - with the number of exports as
    `:count`, and the `:study_id`, `:export_ids` and `:types` as metadata
  * `[:castor_edc, :export, :poll]` - each time `await/4` checks, with the
    number of exports still running as `:pending`, and the `:study_id`
    and `:export_ids` as metadata
  * `[:castor_edc, :export, :completed]` and `[:castor_edc, :export,
    :failed]` - for each export `await/4` sees finish, with the time it
    waited as `:duration` (in native time units), and the `:study_id` and
    `:export` as metadata
  * `[:castor_edc, :export, :timeout]` - when `await/4` gives up, with
    `:duration`, and the `:study_id` and `:export_ids` as metadata

## Concurrent exports

The API runs at most three exports per user at a time, and refuses to
queue more. With `rate_limit: :wait` (the default of `CastorEDC.new/1`),
`queue/4` waits for a slot, trying again after 5 seconds, then 10, 20,
40 and every 60, for as long as its `:timeout` allows. With
`rate_limit: :error`, or once the time is up, it returns an error with
code `:too_many_exports`.

## The struct

  * `:id` - the export's ID
  * `:type` - the export type, such as `:participant_data`
  * `:format` - the file format, such as `:csv`
  * `:status` - `:queued`, `:in_progress`, `:ready` or `:failed`
  * `:file_name` and `:file_size` - the file, once the export is ready
  * `:created_by` - the ID of the user who queued the export
  * `:created_on`, `:completed_on` and `:expires_on` - when the export was
    queued, finished and stops being available (7 days later)
  * `:data` - the downloaded file, when `download/4` kept it in memory
  * `:path` - where `download/4` saved the file, when given `:into`; with
    `unzip: true`, the directory the files went into
  * `:files` - with `unzip: true`, the files in the zip: their paths, or
    `{name, contents}` tuples when the export was kept in memory

Types, formats and statuses the client doesn't know stay strings.

# `format`

```elixir
@type format() ::
  :csv | :excel | :spss | :sas_xpt | :sas_7bdat | :odm | :pdf | :xml | :zip
```

# `status`

```elixir
@type status() :: :queued | :in_progress | :ready | :failed
```

# `t`

```elixir
@type t() :: %CastorEDC.Export{
  completed_on: DateTime.t() | nil,
  created_by: String.t() | nil,
  created_on: DateTime.t() | nil,
  data: binary() | nil,
  expires_on: DateTime.t() | nil,
  file_name: String.t() | nil,
  file_size: non_neg_integer() | nil,
  files: [Path.t()] | [{String.t(), binary()}] | nil,
  format: format() | String.t() | nil,
  id: String.t(),
  path: Path.t() | nil,
  status: status() | String.t() | nil,
  type: type() | String.t() | nil
}
```

# `type`

```elixir
@type type() ::
  :participant_data
  | :participant_casebook
  | :empty_crf
  | :form_structure
  | :queries
  | :survey_compliance
  | :validations
  | :uploaded_files
  | :audit_trail
  | :domain_mapping
  | :sites
```

# `audit_trail`

```elixir
@spec audit_trail(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's audit trail.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv` (`:csv` by default).

Filters: none.

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `await`

```elixir
@spec await(CastorEDC.client(), String.t(), [String.t()], keyword()) ::
  {:ok, [t()]} | {:error, CastorEDC.Error.t()}
```

Waits until every export in `export_ids` is ready, and returns them in
the same order.

It doesn't download them: see `download/4`. When an export fails, it
returns an error with code `:export_failed` and the export in `result`
straight away. An ID that doesn't show up in the export list within 30
seconds returns an error with code `:export_not_found`.

## Options

  * `:timeout` - how long to wait, in milliseconds or `:infinity`; 15
    minutes by default. Then it returns an error with code
    `:export_timeout`, with the IDs of the exports that weren't ready in
    `export_ids`. They keep running, so you can call `await/4` with
    those IDs again.
  * `:poll_interval` - the first wait before checking, in milliseconds;
    1 second by default
  * `:since` - a `DateTime` from before the exports were queued, which
    lets each check stop paging through the export list at older exports

# `domain_mapping`

```elixir
@spec domain_mapping(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The mapping of the study's fields to domains.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv` (`:csv` by default).

Filters: none.

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `download`

```elixir
@spec download(CastorEDC.client(), String.t(), t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

Downloads a ready export.

Every export downloads as a zip. Without `:into`, the file comes back in
memory, in the struct's `:data`.

## Options

  * `:into` - save the file instead, streaming it to disk so it never sits
    in memory as a whole. An existing directory, or a path ending in `/`,
    saves it there under the export's file name; any other path is the
    file to write. Missing directories are created. The struct's `:path`
    says where the file went.

Any other option is passed to `Req`.

An export that isn't ready returns an error with code `:export_not_ready`,
and one past its expiry date an error with code `:export_expired`.

# `empty_crf`

```elixir
@spec empty_crf(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's forms as an empty case report form, in a single PDF.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:pdf` (`:pdf` by default).

Filters:

  * `:elements` (a keyword list of `:forms`, `:repeating_data`, `:repeating_data_forms`, `:survey_forms`, `:surveys`, `:visits`, each a list of IDs)
  * `:paper_size` (one of `:a4paper`, `:letterpaper`; `:a4paper` by default)

Options:

  * `:include_additional_info` (boolean)
  * `:include_calculated_templates` (boolean)
  * `:include_dependencies` (boolean)
  * `:include_helptexts` (boolean)
  * `:include_hidden_calculated_fields` (boolean)
  * `:include_table_of_contents` (boolean)
  * `:include_title_page` (boolean)
  * `:include_validations` (boolean)
  * `:inline_repeated_measure_forms` (boolean)
  * `:start_forms_on_new_page` (boolean)

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; an hour by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `form_structure`

```elixir
@spec form_structure(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's structure: its visits, forms and fields, and those of its repeating data and surveys.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:xml`, `:odm` (`:xml` by default).

Filters:

  * `:element_id` (string)
  * `:element_type` (one of `:all`, `:study`, `:visit`, `:form`, `:field`, `:repeating_data`, `:repeating_data_item`, `:repeating_data_form`, `:repeating_data_field`, `:surveys`, `:survey`, `:survey_form`, `:survey_field`, `:survey_packages`, `:survey_package`)

Options:

  * `:include_annotations` (boolean; `true` by default)
  * `:include_domains` (boolean; `true` by default)

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `participant_casebook`

```elixir
@spec participant_casebook(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

A casebook of each participant's data: a PDF per participant.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:pdf` (`:pdf` by default).

Filters:

  * `:paper_size` (one of `:a4paper`, `:letterpaper`)
  * `:participant_ids` (a list of strings)

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; an hour by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `participant_data`

```elixir
@spec participant_data(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's collected data. In CSV, the zip holds a file for the study's fields, one for each repeating data and one for each survey, together with lists of the variables and option groups.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv`, `:excel`, `:spss`, `:sas_xpt`, `:sas_7bdat`, `:odm` (`:csv` by default).

Filters:

  * `:created_between_end` (a `Date`)
  * `:created_between_start` (a `Date`)
  * `:created_by` (a list of strings)
  * `:elements` (a keyword list of `:forms`, `:repeating_data`, `:repeating_data_forms`, `:survey_forms`, `:surveys`, `:visits`, each a list of IDs)
  * `:last_updated_between_end` (a `Date`)
  * `:last_updated_between_start` (a `Date`)
  * `:locked` (boolean)
  * `:participant_ids` (a list of strings)
  * `:progress` (a list of values from `:not_started`, `:in_progress`, `:completed`, `:archived`)
  * `:randomized` (boolean)
  * `:sdv_pending` (boolean)
  * `:site_ids` (a list of strings)
  * `:subject_status_ids` (a list of strings)
  * `:updated_by` (a list of strings)

Options:

  * `:display_options_as` (one of `:names`, `:numbers`; `:numbers` by default) - Whether Options are exported as numbers (values) or names (labels). Only applicable when `grouped` is set to false. Only applies to `:csv` or `:excel` exports that aren't grouped.
  * `:export_coded_options_as` (one of `:values`, `:values_and_names`; `:values` by default) - Whether Options are exported as values only, or in two columns with both values and names included. Only applicable when `grouped` is set to true. Only applies to `:csv`, `:sas_xpt` or `:sas_7bdat` exports with `grouped: true`.
  * `:export_dates_as` (one of `:date`, `:text`; `:date` by default) - Export dates, date & times, and time fields as SAS date/datetime/time types or as strings. Only applicable when `grouped` is set to true and `format` is `sas_xpt` or `sas_7bdat`. Only applies to `:sas_xpt` or `:sas_7bdat` exports with `grouped: true`.
  * `:export_missing_data_in` (one of `:same_column`, `:separate_column`; `:same_column` by default) - Whether missing data annotations (reason for missing) are exported in the same column as the field, or in a separate column next to the field. Only applicable when `grouped` is set to true. Only applies to `:csv`, `:sas_xpt` or `:sas_7bdat` exports with `grouped: true`.
  * `:grouped` (boolean; `false` by default) - Whether to group participant data by domain. Only applies to `:csv`, `:sas_xpt` or `:sas_7bdat`.
  * `:include_comments` (boolean; `false` by default) - Include comments in the export. Only applicable when `grouped` is set to false. Only applies to `:csv` or `:excel` exports that aren't grouped.
  * `:include_empty_rows` (boolean; `false` by default) - Include data from visits, repeating data instances, and survey instances that are not started yet. Only applicable when `grouped` is set to true. Only applies to `:csv`, `:sas_xpt` or `:sas_7bdat` exports with `grouped: true`.
  * `:include_encrypted_fields` (boolean; `false` by default) - Include encrypted fields should be included in the export. Only applicable when `grouped` is false and Field Encryption is enabled. Only applies to `:csv`, `:excel`, `:spss`, `:sas_xpt` or `:sas_7bdat` exports that aren't grouped.
  * `:include_queries` (boolean; `false` by default) - Include queries in the export. Only applicable when `grouped` is set to false. Only applies to `:csv` or `:excel` exports that aren't grouped.
  * `:include_survey_metadata` (boolean; `false` by default) - Include survey metadata. Only applicable when `grouped` is set to true. Only applies to `:csv`, `:sas_xpt` or `:sas_7bdat` exports with `grouped: true`.
  * `:include_verifications` (boolean; `false` by default) - Include verifications in the export. Only applicable when `grouped` is set to false. Only applies to `:csv` or `:excel` exports that aren't grouped.

The API skips the other filters when `participant_ids` is given, and filters on a creation or update date only with both ends of the range.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `queries`

```elixir
@spec queries(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's queries.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv`, `:excel` (`:csv` by default).

Filters:

  * `:created_between_end` (a `Date`, a `NaiveDateTime` in the server's time or a `DateTime`, to the minute; see `CastorEDC.time_zone/1`)
  * `:created_between_start` (a `Date`, a `NaiveDateTime` in the server's time or a `DateTime`, to the minute; see `CastorEDC.time_zone/1`)
  * `:days_in_current_status_from` (integer)
  * `:days_in_current_status_to` (integer)
  * `:days_since_opened_from` (integer)
  * `:days_since_opened_to` (integer)
  * `:elements` (a keyword list of `:repeating_data`, `:visit_forms`, `:visits`, each a list of IDs)
  * `:statuses` (a list of values from `:new`, `:open`, `:closed`, `:confirmed`, `:unconfirmed`, `:resolved`)
  * `:updated_by` (a list of strings)

Options: none.

`elements` takes one kind of element at a time.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `queue`

```elixir
@spec queue(CastorEDC.client(), String.t(), [{type(), keyword()}], keyword()) ::
  {:ok, [String.t()]} | {:error, CastorEDC.Error.t()}
```

Queues exports, returning their IDs in the order of `requests`.

`requests` is a list of `{type, opts}` tuples, all sent in one request:

    {:ok, [data_id, sites_id]} =
      CastorEDC.Export.queue(client, study_id, [
        {:participant_data, format: :spss, filters: [site_ids: [site_id]]},
        {:sites, []}
      ])

Each export takes these options:

  * `:format` - one of the type's formats, by default its first
  * `:filters` and `:options` - keyword lists of the type's filters and
    options. Values are given as Elixir values: lists, booleans, integers,
    `Date`s (and `NaiveDateTime`s where the API takes a time too), and
    atoms for values from a fixed set, such as
    `display_options_as: :names` or `element_type: :visit`.

A type, format, filter or option the API doesn't support, or a value of
the wrong kind, raises `ArgumentError`.

## Options

  * `:timeout` - how long to wait for a free slot when three exports are
    already running (see [Concurrent exports](#module-concurrent-exports)),
    in milliseconds or `:infinity`; 15 minutes by default

# `sites`

```elixir
@spec sites(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The study's sites.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv` (`:csv` by default).

Filters: none.

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `status`

```elixir
@spec status(CastorEDC.client(), String.t(), String.t()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The current state of an export.

There's no endpoint for a single export, so this pages through the
study's export list, newest first, until it finds `export_id`. An ID that
isn't in the list returns an error with code `:export_not_found`. That
includes an export queued a moment ago: it takes the API a few hundred
milliseconds to list it.

# `survey_compliance`

```elixir
@spec survey_compliance(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

Participants' compliance with their survey packages.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv`, `:excel` (`:csv` by default).

Filters:

  * `:availability_end` (a `Date`, a `NaiveDateTime` in the server's time or a `DateTime`, to the minute; see `CastorEDC.time_zone/1`)
  * `:availability_start` (a `Date`, a `NaiveDateTime` in the server's time or a `DateTime`, to the minute; see `CastorEDC.time_zone/1`)
  * `:compliance_operator` (one of `:>`, `:<`, `:>=`, `:<=`, `:=`)
  * `:compliance_value` (integer)
  * `:mobile` (boolean)
  * `:parent_id` (string)
  * `:parent_type` (one of `:empty`, `:visit`, `:repeating_data`)
  * `:participant_ids` (a list of strings)
  * `:survey_package_ids` (a list of strings)
  * `:survey_package_status` (a list of values from `:created`, `:completed`, `:failed`, `:in_progress`, `:locked`, `:received`, `:sent`, `:viewed`)

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `uploaded_files`

```elixir
@spec uploaded_files(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The files uploaded to the study's upload fields.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:zip` (`:zip` by default).

Filters:

  * `:participant_ids` (a list of strings)

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

# `validations`

```elixir
@spec validations(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, t()} | {:error, CastorEDC.Error.t()}
```

The validation messages entered data triggered.

Queues the export, waits until it's ready and downloads it. Without
`:into`, the zip comes back in memory, in `:data`.

Formats: `:csv`, `:excel` (`:csv` by default).

Filters:

  * `:form_collection_types` (a list of strings)
  * `:participant_id` (a list of strings)
  * `:sites` (a list of strings)
  * `:triggered_after` (a `Date`)
  * `:triggered_before` (a `Date`)
  * `:validation_statuses` (a list of strings)
  * `:validation_types` (a list of strings)

Options: none.

## Options

  * `:format`, `:filters` and `:options` - as above
  * `:into` - a directory, or a file path, to stream the zip to, as for
    `download/4`
  * `:unzip` - when `true`, unzips the export: into the `:into`
    directory (a file path given as `:into` becomes a directory of that
    name), or in memory. The struct's `:files` lists what was in it.
  * `:timeout` - how long to wait for the export, queuing included, in
    milliseconds or `:infinity`; 15 minutes by default
  * `:poll_interval` - the first wait before checking on the export,
    see `await/4`

Any other option is passed to `Req` for the download. A format, filter
or option the export doesn't take raises `ArgumentError` before anything
is sent.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
