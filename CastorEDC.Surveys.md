# `CastorEDC.Surveys`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/surveys.ex#L4)

Surveys, their forms and packages, the instances sent to participants, and survey compliance.

## Operations

  * `create_survey_package_instance/4` - Creates a SurveyPackageInstance and (optionally) send the email invite directly.
  * `get_survey/4` - Retrieve a single Survey
  * `get_survey_form/5` - Retrieve a single SurveyForm
  * `get_survey_package/4` - Retrieve a single Survey Package
  * `get_survey_package_instance/4` - Retrieve a single Survey Package Instance
  * `list_survey_compliance/3` - Retrieve participant survey compliance information
  * `list_survey_forms/4` - Retrieve list of available SurveyForms of a specific Survey
  * `list_survey_package_instances/3` - Retrieve list of available SurveyPackageInstances
  * `list_survey_packages/3` - Retrieve list of available Survey Packages
  * `list_surveys/3` - Retrieve list of available Surveys
  * `update_survey_package_instance/5` - Updates a SurveyPackageInstance. Can be used to lock/unlock or mark as sent.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_survey_package_instance`

```elixir
@spec create_survey_package_instance(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.SurveyPackageInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Creates a SurveyPackageInstance and (optionally) send the email invite directly.

Creates an instantiation of a SurveyPackage for a specific Record.

Sends `POST /api/study/{study_id}/survey-package-instance`. [API reference](https://data.castoredc.com/api#/survey/post_study__study_id__survey_package_instance)

## Arguments

  * `study_id` - The ID of the study to retrieve survey package instances for
  * `body` - a map, sent as JSON: SurveyPackageInstance details to create the object.
    * `ccr_patient_id` (string, required) - The CCR Patient identifier of the Participant to create this SurveyPackageInstance for. Should exist already. Cannot be combined with participant_id. One of "participant_id" or "ccr_patient_id" is required.
    * `participant_id` (string, required) - The identifier of the Participant to create this SurveyPackageInstance for. Should exist already. Cannot be combined with ccr_patient_id. One of "participant_id" or "ccr_patient_id" is required.
    * `survey_package_id` (string, required) - The identifier of the SurveyPackage that should be instantiated in this SurveyPackageInstance.
    * `auto_lock_on_finish` (boolean) - Whether the SurveyPackageInstance should be automatically locked when the survey respondent clicks the finish button at the end of data entry .
    * `available_from` (string) - UTC date and time when the Survey Package Instance should be scheduled. The provided value is converted to server time during creation. Web surveys are scheduled based on **date**, while mobile surveys use **date and time**. If `available_from` is in the past or today, the survey is sent immediately. If in the future, it will be scheduled accordingly. If left empty, the Survey Package Instance will be created but not scheduled.
    * `email_address` (string) - The email address this SurveyPackageInstance will be sent to. If no email_address is provided in the request the system will try to use the Participant's stored email address. The email address is stored encrypted.
    * `package_invitation` (string) - The contents of the invitation message that will be sent. If left empty will inherit the default contents from the SurveyPackage. Must contain a {url} tag that will be replaced with survey_url_string when sending the email. If sending a mobile Survey, it's recommended to reuse the default SurveyPackage invitation message or include the app store tags ({castorconnect-apple-store-link} and {castorconnect-google-store-link}) and the activation QR code tag ({CC-activation-QR}).
    * `package_invitation_subject` (string) - The subject of the invitation message that will be sent. If left empty will inherit the default subject of the SurveyPackage .
    * `parent_id` (string) - The UUID of the parent instance.
    * `parent_type` (string) - 0: No parent. 1: The survey belongs to a visit. 2: The survey belongs to a repeating data instance.

Every option is passed to `Req`.

# `create_survey_package_instance!`

```elixir
@spec create_survey_package_instance!(
  CastorEDC.client(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.SurveyPackageInstance.t()
```

The same as `create_survey_package_instance/4`, returning the result or raising `CastorEDC.Error`.

# `get_survey`

```elixir
@spec get_survey(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Survey.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Survey.

Sends `GET /api/study/{study_id}/survey/{survey_id}`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey__survey_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_id` - The ID of the survey for which this call should be made

## Options

  * `:include` (list of string, sent comma-separated) - Adds the option of including survey forms in the query. Use like: ?include=forms

Any other option is passed to `Req`.

# `get_survey!`

```elixir
@spec get_survey!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Survey.t()
```

The same as `get_survey/4`, returning the result or raising `CastorEDC.Error`.

# `get_survey_form`

```elixir
@spec get_survey_form(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.SurveyForm.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single SurveyForm.

Sends `GET /api/study/{study_id}/survey/{survey_id}/survey-form/{survey_form_id}`. [API reference](https://data.castoredc.com/api#/survey-form/get_study__study_id__survey__survey_id__survey_form__survey_form_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_id` - The ID of the survey for which this call should be made
  * `survey_form_id` - ID of the SurveyForm to fetch

Every option is passed to `Req`.

# `get_survey_form!`

```elixir
@spec get_survey_form!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Model.SurveyForm.t()
```

The same as `get_survey_form/5`, returning the result or raising `CastorEDC.Error`.

# `get_survey_package`

```elixir
@spec get_survey_package(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.SurveyPackage.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Survey Package.

Sends `GET /api/study/{study_id}/survey-package/{survey_package_id}`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey_package__survey_package_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_package_id` - Survey Package ID of the Survey Package to fetch

## Options

  * `:include` (list of string, sent comma-separated) - Adds the option of including fields in the query. Use like: ?include=fields

Any other option is passed to `Req`.

# `get_survey_package!`

```elixir
@spec get_survey_package!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.SurveyPackage.t()
```

The same as `get_survey_package/4`, returning the result or raising `CastorEDC.Error`.

# `get_survey_package_instance`

```elixir
@spec get_survey_package_instance(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.SurveyPackageInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a single Survey Package Instance.

Sends `GET /api/study/{study_id}/survey-package-instance/{survey_package_instance_id}`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey_package_instance__survey_package_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_package_instance_id` - Survey Package Instance ID of the Survey Package Instance to fetch

Every option is passed to `Req`.

# `get_survey_package_instance!`

```elixir
@spec get_survey_package_instance!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Model.SurveyPackageInstance.t()
```

The same as `get_survey_package_instance/4`, returning the result or raising `CastorEDC.Error`.

# `list_survey_compliance`

```elixir
@spec list_survey_compliance(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Compliance.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve participant survey compliance information.

Retrieves participant survey compliance. Result is based on the site permissions of the API user.

Sends `POST /api/study/{study_id}/compliance`. [API reference](https://data.castoredc.com/api#/survey/post_study__study_id__compliance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer) - The size of pages
  * `:sort` (string) - The field to sort on, the default is `participantId`. All available ones are: siteName, participantId, participantStatus, compliance, totalSurveys, completedSurveys
  * `:dir` (string) - Sorting direction of the results ASC or DESC, defaults to ASC
  * `:participant_ids` (list of string) - Returns compliance result filtered on given participants.
  * `:availability_start` (string) - Returns all surveys available for completion between availabilityStart and availabilityEnd dates. Supported format Y-m-d H:i:s
  * `:availability_end` (string) - Returns all surveys available for completion between availabilityStart and availabilityEnd dates Supported format Y-m-d H:i:s
  * `:site_ids` (list of string) - Returns compliance result filtered on given sites.
  * `:participant_statuses` (list of string) - Returns compliance result filtered on given participant statuses.
  * `:survey_package_ids` (list of string) - Returns compliance result filtered on given survey packages.
  * `:survey_package_statuses` (list of string) - Returns compliance result filtered on survey package status. Available ones are: Created, Completed, Failed, In Progress, Locked, Received, Sent, Viewed
  * `:mobile` (boolean) - Filter on mobile surveys. Requires mobile surveys to be enabled on the study.
  * `:compliance` (integer) - Compliance percentage to filter on, integer between 0 and 100. Requires complianceOption to be set.
  * `:compliance_option` (string, one of `=`, `>`, `<`, `<=`, `>=`) - Logical operator to be combined with "compliance" parameter.
  * `:parent_id` (string) - UUID of the visit or repeating data survey parent. Requires the "parentType" parameter.
  * `:parent_type` (string, one of `0`, `1`, `2`) - 0: No parent. 1: Surveys belongs to a visit. 2: The surveys belongs to a repeating data instance.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Compliance.t/0` records.

# `list_survey_compliance!`

```elixir
@spec list_survey_compliance!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Compliance.t())
```

The same as `list_survey_compliance/3`, returning the result or raising `CastorEDC.Error`.

# `list_survey_forms`

```elixir
@spec list_survey_forms(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.SurveyForm.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available SurveyForms of a specific Survey.

Gets `SurveyForm` objects, which are Forms that are collected only once per survey.
SurveyForms are placed in a Survey and contain Fields.

Sends `GET /api/study/{study_id}/survey/{survey_id}/survey-form`. [API reference](https://data.castoredc.com/api#/survey-form/get_study__study_id__survey__survey_id__survey_form)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_id` - The ID of the survey for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.SurveyForm.t/0` records.

# `list_survey_forms!`

```elixir
@spec list_survey_forms!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.SurveyForm.t())
```

The same as `list_survey_forms/4`, returning the result or raising `CastorEDC.Error`.

# `list_survey_package_instances`

```elixir
@spec list_survey_package_instances(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.SurveyPackageInstance.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available SurveyPackageInstances.

Gets `SurveyPackageInstance` objects, which are 'instantiations' of SurveyPackages.
The SurveyPackageInstance (SPI) is the entity to which the data gets saved, for which email invitations are sent, etc.

Sends `GET /api/study/{study_id}/survey-package-instance`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey_package_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The size of pages
  * `:participant_id` (string) - Filter survey package invitations based on participant id. Cannot be combined with "ccr_patient_id"
  * `:ccr_patient_id` (string) - Filter survey package invitations based on CCR patient id. Cannot be combined with "participant_id"
  * `:sort` (string) - The field to sort on, the default is `createdOn`. All available ones are: availableFrom, progress, createdOn, updatedOn, sentOn, locked, archived, record_id, siteName, survey_package_name, status, finishedOn, startedOn, isMobile, expiresOn
  * `:dir` (string) - Sorting direction of the results ASC or DESC, defaults to ASC
  * `:available_from_start` (string) - Filter on survey `available_from` field based on a date range. Requires available_from_end. Supported format Y-m-d H:i:s
  * `:available_from_end` (string) - Filter on survey `available_from` field based on a date range. Requires available_from_start. Supported format Y-m-d H:i:s
  * `:available` (boolean) - If the survey is available based on the current server datetime.
  * `:archived` (boolean) - Filter on surveys that have been archived.
  * `:repeatable` (boolean) - Filter on surveys that have been generated from a repeatable survey.
  * `:training` (boolean) - Filter on surveys belonging to a training configured survey package.
  * `:status` (string) - Status to filter on - available ones are: Created, Completed, Failed, In Progress, Locked, Received, Sent, Viewed
  * `:availability_window_start` (string) - Filter to return surveys that were available for completion within the given time period. Requires availability_window_end. Supported format Y-m-d H:i:s
  * `:availability_window_end` (string) - Filter to return surveys that were available for completion within the given time period. Requires availability_window_start. Supported format Y-m-d H:i:s
  * `:finished_on` (string) - Filter survey package invitations based on finished date. Multiple modifiers can be applied. Supported formats: 2021-03-20, 2021-03-20 12:34:56, 2021-03-20T12:34:56Z
  * `:finished_after` (string) - Filter survey package invitations that has finished date greater than provided.
  * `:finished_on_or_after` (string) - Filter survey package invitations that has finished date greater or equal to provided.
  * `:finished_before` (string) - Filter survey package invitations that has finished date lower than provided.
  * `:finished_on_or_before` (string) - Filter survey package invitations that has finished date lower or equal to provided.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.SurveyPackageInstance.t/0` records.

# `list_survey_package_instances!`

```elixir
@spec list_survey_package_instances!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.SurveyPackageInstance.t())
```

The same as `list_survey_package_instances/3`, returning the result or raising `CastorEDC.Error`.

# `list_survey_packages`

```elixir
@spec list_survey_packages(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.SurveyPackage.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available Survey Packages.

Gets `SurveyPackage` objects. A Survey Package is a collection of 1 or more Surveys.
SurveyPackages get instantiated through SurveyPackageInstances, which are the objects
to which datapoints really get stored.

Sends `GET /api/study/{study_id}/survey-package`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey_package)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.SurveyPackage.t/0` records.

# `list_survey_packages!`

```elixir
@spec list_survey_packages!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.SurveyPackage.t())
```

The same as `list_survey_packages/3`, returning the result or raising `CastorEDC.Error`.

# `list_surveys`

```elixir
@spec list_surveys(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Survey.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available Surveys.

Gets `Survey` objects. Surveys consist of Survey Forms. Multiple surveys can be combined in
Survey Packages, which are being sent to respondents using Survey Package Instances.

Sends `GET /api/study/{study_id}/survey`. [API reference](https://data.castoredc.com/api#/survey/get_study__study_id__survey)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:include` (list of string, sent comma-separated) - Adds the option of including survey forms in the query. Use like: ?include=forms
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Survey.t/0` records.

# `list_surveys!`

```elixir
@spec list_surveys!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Survey.t())
```

The same as `list_surveys/3`, returning the result or raising `CastorEDC.Error`.

# `stream_survey_compliance`

```elixir
@spec stream_survey_compliance(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Compliance.t())
```

Streams every record `list_survey_compliance/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, in the API's default page size unless `:page_size` says
otherwise; see `CastorEDC.Pagination`.

# `stream_survey_forms`

```elixir
@spec stream_survey_forms(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.SurveyForm.t())
```

Streams every record `list_survey_forms/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_survey_package_instances`

```elixir
@spec stream_survey_package_instances(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.SurveyPackageInstance.t())
```

Streams every record `list_survey_package_instances/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_survey_packages`

```elixir
@spec stream_survey_packages(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.SurveyPackage.t())
```

Streams every record `list_survey_packages/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_surveys`

```elixir
@spec stream_surveys(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Survey.t())
```

Streams every record `list_surveys/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `update_survey_package_instance`

```elixir
@spec update_survey_package_instance(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  {:ok, CastorEDC.Model.SurveyPackageInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Updates a SurveyPackageInstance. Can be used to lock/unlock or mark as sent.

The endpoint allows updating **either** the `locked` status or the `sent_on` datetime of a SurveyPackageInstance.

⚠️ These options are **mutually exclusive**—only one operation is allowed per request.

### Locking/Unlocking
- Accepts a `boolean` (`true` or `false`).
- Used to **lock or unlock** a SurveyPackageInstance.

### Marking as sent
- Accepts a **past** date in **UTC format** (`YYYY-MM-DD HH:MM:SS`).
- Only applicable for unsent SurveyPackageInstances in the `Created` status.
- Updating `sent_on` will:
  - Set **both** `available_from` and `sent_on` to the submitted date.
  - Update the SurveyPackageInstance status to `Sent`.

Sends `PATCH /api/study/{study_id}/survey-package-instance/{survey_package_instance_id}`. [API reference](https://data.castoredc.com/api#/survey/patch_study__study_id__survey_package_instance__survey_package_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `survey_package_instance_id` - The ID of the SurveyPackageInstance to update.
  * `body` - a map, sent as JSON: SurveyPackageInstance details to patch the object.
    * `locked` (boolean) - Set to true to lock or false to unlock the SurveyPackageInstance. Cannot be combined with "status".
    * `sent_on` (string) - The UTC date and time when the survey has been sent. Cannot be combined with "locked".

Every option is passed to `Req`.

# `update_survey_package_instance!`

```elixir
@spec update_survey_package_instance!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.SurveyPackageInstance.t()
```

The same as `update_survey_package_instance/5`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
