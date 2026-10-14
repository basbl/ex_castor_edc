# `CastorEDC.DataPoints`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/data_points.ex#L4)

The values collected for participants: reading them per study, per participant or per survey, repeating data or survey package instance, and writing them one at a time or in bulk. Values are strings; see CastorEDC.FieldValue for decoding them by field type.

## Operations

  * `create_repeating_data_data_point/7` - Create a field result for a repeating data instance
  * `create_study_data_point/6` - Create a field result
  * `create_survey_data_point/7` - Create a field result for a survey (package) instance 🔭
  * `create_survey_package_instance_with_data_points/5` - Create a new repeatable survey package instance and a collection of field values for it 🔭
  * `get_repeating_data_data_point/6` - Retrieve a single RepeatingDataInstanceFieldResult object
  * `get_study_data_point/5` - Retrieve a single FieldResult object
  * `get_survey_data_point/6` - Retrieve a single SurveyInstanceFieldResult object 🔭
  * `list_participant_repeating_data_data_points/4` - Retrieves a list of all repeating data data collected for this participant
  * `list_participant_repeating_data_instance_data_points/5` - Retrieves a list of all repeating data data collected for this repeating data instance
  * `list_participant_study_data_points/4` - Retrieves a list of all study data collected for this participant
  * `list_participant_survey_data_points/4` - Retrieves a list of all survey data collected for this participant
  * `list_participant_survey_instance_data_points/5` - Retrieves a list of all survey data collected for this survey instance
  * `list_participant_survey_package_instance_data_points/5` - Retrieves a list of all survey data collected for this survey package instance 🔭
  * `list_repeating_data_data_points/3` - Retrieves a list of all repeating data data collected for all participants
  * `list_repeating_data_instance_data_points/4` - Retrieves a list of all repeating data data collected for this repeating data instance
  * `list_study_data_points/3` - Retrieves a list of all study data collected for all participants
  * `list_survey_data_points/3` - Retrieves a list of all survey data collected for all participants
  * `list_survey_instance_data_points/4` - Retrieves a list of all survey data collected for this survey instance
  * `list_survey_package_instance_data_points/4` - Retrieves a list of all survey data collected for this survey package instance
  * `upsert_repeating_data_instance_data_points/6` - Create/update a collection of field values for a repeating data instance
  * `upsert_study_data_points/5` - Create/update a collection of field values for a study
  * `upsert_survey_instance_data_points/6` - Create/update a collection of field values for a survey instance
  * `upsert_survey_package_instance_data_points/6` - Create/update a collection of field values for a survey package instance

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_repeating_data_data_point`

```elixir
@spec create_repeating_data_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Create a field result for a repeating data instance.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-point/repeating-data/{repeating_data_instance_id}/{field_id}`. [API reference](https://data.castoredc.com/api#/repeating-data-data-entry/post_study__study_id__participant__participant_id__data_point_repeating_data__repeating_data_instance_id___field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant
  * `repeating_data_instance_id` - ID of the repeating data instance
  * `field_id` - ID of the field
  * `body` - a map, sent as JSON
    * `change_reason` (string) - Required change reason when changing an existing data point that is verified or signed, or when GCP is enabled and there is already a data point that is being changed.
    * `confirmed_changes` (boolean) - Required when changing an existing data point that is verified or signed. Note that you also have to provide "change_reason".
    * `field_value` (string) - The value. If empty, it will clear any stored value, including uploaded files.
    * `upload_file` (string) - A file to upload as the value, instead of field_value: `{file name, contents}` or a `File.Stream`. The request then goes as multipart form data. The upload limit is 2 MB.

Every option is passed to `Req`.

# `create_repeating_data_data_point!`

```elixir
@spec create_repeating_data_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPoint.t()
```

The same as `create_repeating_data_data_point/7`, returning the result or raising `CastorEDC.Error`.

# `create_study_data_point`

```elixir
@spec create_study_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Create a field result.

Sends `POST /api/study/{study_id}/participant/{participant_id}/study-data-point/{field_id}`. [API reference](https://data.castoredc.com/api#/study-data-entry/post_study__study_id__participant__participant_id__study_data_point__field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant
  * `field_id` - ID of the field
  * `body` - a map, sent as JSON
    * `change_reason` (string) - Required change reason when changing an existing data point that is verified or signed, or when GCP is enabled and there is already a data point that is being changed.
    * `confirmed_changes` (boolean) - Required when changing an existing data point that is verified or signed. Note that you also have to provide "change_reason".
    * `field_value` (string) - The value. If empty, it will clear any stored value, including uploaded files.
    * `upload_file` (string) - A file to upload as the value, instead of field_value: `{file name, contents}` or a `File.Stream`. The request then goes as multipart form data. The upload limit is 2 MB.

Every option is passed to `Req`.

# `create_study_data_point!`

```elixir
@spec create_study_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.DataPoint.t()
```

The same as `create_study_data_point/6`, returning the result or raising `CastorEDC.Error`.

# `create_survey_data_point`

```elixir
@spec create_survey_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Create a field result for a survey (package) instance 🔭.

Create a field result for a survey (package) instance. Supports the `record` scope.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-point/survey/{survey_instance_id}/{field_id}`. [API reference](https://data.castoredc.com/api#/survey-data-entry/post_study__study_id__participant__participant_id__data_point_survey__survey_instance_id___field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant
  * `survey_instance_id` - ID of the survey instance or its parent survey package instance
  * `field_id` - The field identifier
  * `body` - a map, sent as JSON
    * `change_reason` (string) - Required change reason when GCP is enabled and there is already a data point that is being changed.
    * `field_value` (string) - The value. If empty, it will clear any stored value, including uploaded files.
    * `upload_file` (string) - A file to upload as the value, instead of field_value: `{file name, contents}` or a `File.Stream`. The request then goes as multipart form data. The upload limit is 2 MB.

Every option is passed to `Req`.

# `create_survey_data_point!`

```elixir
@spec create_survey_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPoint.t()
```

The same as `create_survey_data_point/7`, returning the result or raising `CastorEDC.Error`.

# `create_survey_package_instance_with_data_points`

```elixir
@spec create_survey_package_instance_with_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPointsResult.t()} | {:error, CastorEDC.Error.t()}
```

Create a new repeatable survey package instance and a collection of field values for it 🔭.

Create a new repeatable survey package instance and a collection of field values for it

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-points/survey-package-instance`. [API reference](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_survey_package_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `body` - a map, sent as JSON: Parameters common to all data points that will be created.You can provide an additional "all_fields_filled_on" parameter to mark the actual time the Survey Package Instance has been completed
    * `all_fields_filled_on` (string) - The UTC date and time the Survey Package Instance has been completed and all its fields have been filled
    * `data` (list of map)
      * `field_id` (string, required) - The field identifier
      * `field_value` (string, required) - The value
      * `survey_id` (string, required) - The SurveyId to save the data-points for
    * `survey_package_id` (string) - The ID of the repeatable survey package for which a new survey package instance should be created.
    * `survey_package_instance_id` (string) - Optional client-provided UUID for the survey package instance. If not provided, the server will generate one. If provided and already exists, the request will return a 400 error.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `create_survey_package_instance_with_data_points!`

```elixir
@spec create_survey_package_instance_with_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPointsResult.t()
```

The same as `create_survey_package_instance_with_data_points/5`, returning the result or raising `CastorEDC.Error`.

# `get_repeating_data_data_point`

```elixir
@spec get_repeating_data_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single RepeatingDataInstanceFieldResult object.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-point/repeating-data/{repeating_data_instance_id}/{field_id}`. [API reference](https://data.castoredc.com/api#/repeating-data-data-entry/get_study__study_id__participant__participant_id__data_point_repeating_data__repeating_data_instance_id___field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - ID of the participant
  * `repeating_data_instance_id` - ID of the repeating data instance
  * `field_id` - ID of the field

## Options

  * `:validations` (boolean, defaults to `false`) - Whether to include each field's validations.

Any other option is passed to `Req`.

# `get_repeating_data_data_point!`

```elixir
@spec get_repeating_data_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Model.DataPoint.t()
```

The same as `get_repeating_data_data_point/6`, returning the result or raising `CastorEDC.Error`.

# `get_study_data_point`

```elixir
@spec get_study_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single FieldResult object.

Sends `GET /api/study/{study_id}/participant/{participant_id}/study-data-point/{field_id}`. [API reference](https://data.castoredc.com/api#/study-data-entry/get_study__study_id__participant__participant_id__study_data_point__field_id_)

## Arguments

  * `study_id` - The ID of the study to retrieve FieldResults for
  * `participant_id` - ID of the participant
  * `field_id` - ID of the field

## Options

  * `:validations` (boolean, defaults to `false`) - Whether to include each field's validations.

Any other option is passed to `Req`.

# `get_study_data_point!`

```elixir
@spec get_study_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Model.DataPoint.t()
```

The same as `get_study_data_point/5`, returning the result or raising `CastorEDC.Error`.

# `get_survey_data_point`

```elixir
@spec get_survey_data_point(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPoint.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single SurveyInstanceFieldResult object 🔭.

 Supports the `record` scope.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-point/survey/{survey_instance_id}/{field_id}`. [API reference](https://data.castoredc.com/api#/survey-data-entry/get_study__study_id__participant__participant_id__data_point_survey__survey_instance_id___field_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - ID of the participant
  * `survey_instance_id` - ID of the survey (package) instance
  * `field_id` - ID of the field

## Options

  * `:validations` (boolean, defaults to `false`) - Whether to include each field's validations.

Any other option is passed to `Req`.

# `get_survey_data_point!`

```elixir
@spec get_survey_data_point!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Model.DataPoint.t()
```

The same as `get_survey_data_point/6`, returning the result or raising `CastorEDC.Error`.

# `list_participant_repeating_data_data_points`

```elixir
@spec list_participant_repeating_data_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all repeating data data collected for this participant.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/repeating-data-instance`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_repeating_data_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_repeating_data_data_points!`

```elixir
@spec list_participant_repeating_data_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_repeating_data_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `list_participant_repeating_data_instance_data_points`

```elixir
@spec list_participant_repeating_data_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all repeating data data collected for this repeating data instance.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/repeating-data-instance/{repeating_data_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_repeating_data_instance__repeating_data_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `repeating_data_instance_id` - The ID of the repeating data instance to retrieve all data-points from

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_repeating_data_instance_data_points!`

```elixir
@spec list_participant_repeating_data_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_repeating_data_instance_data_points/5`, returning the result or raising `CastorEDC.Error`.

# `list_participant_study_data_points`

```elixir
@spec list_participant_study_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all study data collected for this participant.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/study`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_study)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_study_data_points!`

```elixir
@spec list_participant_study_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_study_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `list_participant_survey_data_points`

```elixir
@spec list_participant_survey_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for this participant.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/survey-instance`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_survey_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_survey_data_points!`

```elixir
@spec list_participant_survey_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_survey_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `list_participant_survey_instance_data_points`

```elixir
@spec list_participant_survey_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for this survey instance.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/survey-instance/{survey_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_survey_instance__survey_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `survey_instance_id` - The ID of the survey instance to retrieve all data-points from

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_survey_instance_data_points!`

```elixir
@spec list_participant_survey_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_survey_instance_data_points/5`, returning the result or raising `CastorEDC.Error`.

# `list_participant_survey_package_instance_data_points`

```elixir
@spec list_participant_survey_package_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for this survey package instance 🔭.

Supports the `record` scope.

Sends `GET /api/study/{study_id}/participant/{participant_id}/data-points/survey-package-instance/{survey_package_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__participant__participant_id__data_points_survey_package_instance__survey_package_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `survey_package_instance_id` - The ID of the survey package instance to retrieve all data-points from.

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_participant_survey_package_instance_data_points!`

```elixir
@spec list_participant_survey_package_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_participant_survey_package_instance_data_points/5`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data_data_points`

```elixir
@spec list_repeating_data_data_points(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all repeating data data collected for all participants.

Sends `GET /api/study/{study_id}/data-points/repeating-data-instance`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_repeating_data_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_repeating_data_data_points!`

```elixir
@spec list_repeating_data_data_points!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_repeating_data_data_points/3`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data_instance_data_points`

```elixir
@spec list_repeating_data_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all repeating data data collected for this repeating data instance.

Sends `GET /api/study/{study_id}/data-points/repeating-data-instance/{repeating_data_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_repeating_data_instance__repeating_data_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `repeating_data_instance_id` - The ID of the repeating data instance to retrieve all data-points from

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_repeating_data_instance_data_points!`

```elixir
@spec list_repeating_data_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_repeating_data_instance_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `list_study_data_points`

```elixir
@spec list_study_data_points(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all study data collected for all participants.

Sends `GET /api/study/{study_id}/data-points/study`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_study)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_study_data_points!`

```elixir
@spec list_study_data_points!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_study_data_points/3`, returning the result or raising `CastorEDC.Error`.

# `list_survey_data_points`

```elixir
@spec list_survey_data_points(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for all participants.

Sends `GET /api/study/{study_id}/data-points/survey-instance`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_survey_data_points!`

```elixir
@spec list_survey_data_points!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_survey_data_points/3`, returning the result or raising `CastorEDC.Error`.

# `list_survey_instance_data_points`

```elixir
@spec list_survey_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for this survey instance.

Sends `GET /api/study/{study_id}/data-points/survey-instance/{survey_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance__survey_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_instance_id` - The ID of the survey instance to retrieve all data-points from

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_survey_instance_data_points!`

```elixir
@spec list_survey_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_survey_instance_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `list_survey_package_instance_data_points`

```elixir
@spec list_survey_package_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieves a list of all survey data collected for this survey package instance.

Sends `GET /api/study/{study_id}/data-points/survey-package-instance/{survey_package_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_package_instance__survey_package_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_package_instance_id` - The ID of the survey package instance to retrieve all data-points from.

## Options

  * `:field_ids` (list of string, sent comma-separated) - Comma-separated list of field UUIDs to filter the results. Only data points for the specified fields will be returned.
  * `:updated_after` (string) - Only data points updated strictly after this time, as ISO 8601 with an offset. Data points' updated_on is the server's local time, so build it with `updated_on |> DateTime.from_naive!(CastorEDC.time_zone(client), Tz.TimeZoneDatabase) |> DateTime.to_iso8601()`.
  * `:page` (integer, defaults to `1`) - The page to retrieve.
  * `:page_size` (integer, at most `5000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.DataPoint.t/0` records.

# `list_survey_package_instance_data_points!`

```elixir
@spec list_survey_package_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.DataPoint.t())
```

The same as `list_survey_package_instance_data_points/4`, returning the result or raising `CastorEDC.Error`.

# `stream_repeating_data_data_points`

```elixir
@spec stream_repeating_data_data_points(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_repeating_data_data_points/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_repeating_data_instance_data_points`

```elixir
@spec stream_repeating_data_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_repeating_data_instance_data_points/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_study_data_points`

```elixir
@spec stream_study_data_points(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_study_data_points/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_survey_data_points`

```elixir
@spec stream_survey_data_points(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_survey_data_points/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_survey_instance_data_points`

```elixir
@spec stream_survey_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_survey_instance_data_points/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_survey_package_instance_data_points`

```elixir
@spec stream_survey_package_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.DataPoint.t())
```

Streams every record `list_survey_package_instance_data_points/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `upsert_repeating_data_instance_data_points`

```elixir
@spec upsert_repeating_data_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPointsResult.t()} | {:error, CastorEDC.Error.t()}
```

Create/update a collection of field values for a repeating data instance.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-points/repeating-data-instance/{repeating_data_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_repeating_data_instance__repeating_data_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `repeating_data_instance_id` - The ID of the repeating data instance to save the data-points on.
  * `body` - a map, sent as JSON: Parameters common to all data points that will be changed change_reason is required when changing an existing data point for a study with Good Clinical Practice functionality enabled. confirmed_changes and change_reason are required when updating a signed or verified form.
    * `common` (map)
      * `change_reason` (string) - The reason for changing an existing data-point (required if Good Clinical Practice functionality is enabled for the given Study)
      * `confirmed_changes` (boolean) - User confirmed consequent changes after this field value update (i.e. automatic dependency clearing, signature drops, verification drops).
    * `data` (list of map)
      * `field_id` (string, required) - The field identifier
      * `field_value` (string, required) - The value
      * `instance_id` (string, required) - The Repeating Data Instance identifier of the RepeatingDataInstance to save the data points on.
      * `change_reason` (string) - The reason for changing an existing data-point (required if Good Clinical Practice functionality is enabled for the given Study)
      * `confirmed_changes` (boolean) - User confirmed consequent changes after this field value update

    Each item of `data` that has no `instance_id` gets `repeating_data_instance_id`, so it doesn't need repeating.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `upsert_repeating_data_instance_data_points!`

```elixir
@spec upsert_repeating_data_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPointsResult.t()
```

The same as `upsert_repeating_data_instance_data_points/6`, returning the result or raising `CastorEDC.Error`.

# `upsert_study_data_points`

```elixir
@spec upsert_study_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  {:ok, CastorEDC.Model.DataPointsResult.t()} | {:error, CastorEDC.Error.t()}
```

Create/update a collection of field values for a study.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-points/study`. [API reference](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_study)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `body` - a map, sent as JSON: Parameters common to all data points that will be changed change_reason is required when changing an existing data point for a study with Good Clinical Practice functionality enabled. confirmed_changes and change_reason are required when updating a signed or verified form.
    * `common` (map)
      * `change_reason` (string) - The reason for changing an existing data-point (required if Good Clinical Practice functionality is enabled for the given Study)
      * `confirmed_changes` (boolean) - User confirmed consequent changes after this field value update (i.e. automatic dependency clearing, signature drops, verification drops).
    * `data` (list of map)
      * `field_id` (string, required) - The field identifier
      * `field_value` (string, required) - The value
      * `change_reason` (string) - The reason for changing an existing data-point (required if Good Clinical Practice functionality is enabled for the given Study)
      * `confirmed_changes` (boolean) - User confirmed consequent changes after this field value update

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `upsert_study_data_points!`

```elixir
@spec upsert_study_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.DataPointsResult.t()
```

The same as `upsert_study_data_points/5`, returning the result or raising `CastorEDC.Error`.

# `upsert_survey_instance_data_points`

```elixir
@spec upsert_survey_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPointsResult.t()} | {:error, CastorEDC.Error.t()}
```

Create/update a collection of field values for a survey instance.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-points/survey-instance/{survey_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_survey_instance__survey_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `survey_instance_id` - The ID of the survey instance to save all data-points to.
  * `body` - a map, sent as JSON: Parameters common to all data points that will be changed.
    * `data` (list of map)
      * `field_id` (string, required) - The field identifier
      * `field_value` (string, required) - The value
      * `instance_id` (string, required) - The Survey(Package)InstanceId to save the data-points for

    Each item of `data` that has no `instance_id` gets `survey_instance_id`, so it doesn't need repeating.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `upsert_survey_instance_data_points!`

```elixir
@spec upsert_survey_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPointsResult.t()
```

The same as `upsert_survey_instance_data_points/6`, returning the result or raising `CastorEDC.Error`.

# `upsert_survey_package_instance_data_points`

```elixir
@spec upsert_survey_package_instance_data_points(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: {:ok, CastorEDC.Model.DataPointsResult.t()} | {:error, CastorEDC.Error.t()}
```

Create/update a collection of field values for a survey package instance.

Sends `POST /api/study/{study_id}/participant/{participant_id}/data-points/survey-package-instance/{survey_package_instance_id}`. [API reference](https://data.castoredc.com/api#/data-points/post_study__study_id__participant__participant_id__data_points_survey_package_instance__survey_package_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which this call should be made
  * `survey_package_instance_id` - The ID of the survey package instance to save all data-points to.
  * `body` - a map, sent as JSON: Parameters common to all data points that will be changed.You can provide an additional "all_fields_filled_on" parameter to mark the actual time the Survey Package Instance has been completed
    * `all_fields_filled_on` (string) - The UTC date and time the Survey Package Instance has been completed and all its fields have been filled
    * `data` (list of map)
      * `field_id` (string, required) - The field identifier
      * `field_value` (string, required) - The value
      * `instance_id` (string, required) - The Survey(Package)InstanceId to save the data-points for

    Each item of `data` that has no `instance_id` gets `survey_package_instance_id`, so it doesn't need repeating.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `upsert_survey_package_instance_data_points!`

```elixir
@spec upsert_survey_package_instance_data_points!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  map(),
  keyword()
) :: CastorEDC.Model.DataPointsResult.t()
```

The same as `upsert_survey_package_instance_data_points/6`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
