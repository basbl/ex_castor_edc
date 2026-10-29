# `CastorEDC.Participants`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/participants.ex#L4)

The participants of a study, and their progress through its forms.

## Operations

  * `create_participant/4` - Create a participant
  * `get_participant/4` - Retrieve a single Participant 🔭
  * `list_form_progress/3` - Retrieve information about forms filled for participants
  * `list_participants/3` - Retrieve list of study participants
  * `list_repeating_data_progress/4` - Fetch repeating data progress per participant
  * `list_visit_progress/4` - Fetch visit progress per participant

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_participant`

```elixir
@spec create_participant(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.Participant.t()} | {:error, CastorEDC.Error.t()}
```

Create a participant.

Create a new participant for a specific study.
                    You need to set your study's participant id generation strategy to _Patient Study ID (free text)_
                    to be able to supply your own participant id

Sends `POST /api/study/{study_id}/participant`. [API reference](https://data.castoredc.com/api#/participant/post_study__study_id__participant)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `body` - a map, sent as JSON: Participant to add to the Study _participant_id_ can only be set if your study's participant id generation strategy is set to _Patient Study ID (free text)_ and is then a required parameter. If your study uses clinical identifiers via ccr_patient_id you can supply this as an optional parameter.
    * `site_id` (string, required)
    * `ccr_patient_id` (string)
    * `email_address` (string)
    * `participant_id` (string)

Every option is passed to `Req`.

# `create_participant!`

```elixir
@spec create_participant!(CastorEDC.client(), String.t(), map(), keyword()) ::
  CastorEDC.Model.Participant.t()
```

The same as `create_participant/4`, returning the result or raising `CastorEDC.Error`.

# `get_participant`

```elixir
@spec get_participant(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Participant.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Participant 🔭.

Supports the `record` scope.

Sends `GET /api/study/{study_id}/participant/{participant_id}`. [API reference](https://data.castoredc.com/api#/participant/get_study__study_id__participant__participant_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - Participant ID of the Participant to fetch

Every option is passed to `Req`.

# `get_participant!`

```elixir
@spec get_participant!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Participant.t()
```

The same as `get_participant/4`, returning the result or raising `CastorEDC.Error`.

# `list_form_progress`

```elixir
@spec list_form_progress(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.ParticipantProgress.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve information about forms filled for participants.

Gets `Participant Progress` objects, which are Participant Forms that are going to show how much of a participant has been sdv\'d,
signed and locked.

Sends `GET /api/study/{study_id}/participant-progress/forms`. [API reference](https://data.castoredc.com/api#/participant-progress/get_study__study_id__participant_progress_forms)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer) - Page of participants to be returned
  * `:page_size` (integer) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.ParticipantProgress.t/0` records.

# `list_form_progress!`

```elixir
@spec list_form_progress!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.ParticipantProgress.t())
```

The same as `list_form_progress/3`, returning the result or raising `CastorEDC.Error`.

# `list_participants`

```elixir
@spec list_participants(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Participant.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of study participants.

Gets `Participant` objects.

Sends `GET /api/study/{study_id}/participant`. [API reference](https://data.castoredc.com/api#/participant/get_study__study_id__participant)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:site_id` (string) - Site UUID to filter on. Use like: ?site=SITE_ID
  * `:archived` (boolean) - `true` for only archived participants, `false` for only unarchived ones; all participants when left out.
  * `:fields` (a map of keys to values, sent as `field[key]=value`) - Filter participants on field values (participant, survey, report fields). Multiple fields can be defined. Use like: ?field[ID1]=VALUE1&field[ID2]=VALUE2
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Participant.t/0` records.

# `list_participants!`

```elixir
@spec list_participants!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Participant.t())
```

The same as `list_participants/3`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data_progress`

```elixir
@spec list_repeating_data_progress(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok,
   CastorEDC.Page.t(
     CastorEDC.Model.ParticipantProgressRepeatingDataCollection.t()
   )}
  | {:error, CastorEDC.Error.t()}
```

Fetch repeating data progress per participant.

Sends `GET /api/study/{study_id}/participant-progress/{participant_id}/repeating-data`. [API reference](https://data.castoredc.com/api#/participant-progress/get_study__study_id__participant_progress__participant_id__repeating_data)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which to retrieve progress

## Options

  * `:archived` (boolean) - `true` for only archived repeating data instances, `false` (what the API does when it's left out) for only unarchived ones.
  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `100`; a larger one is lowered to it) - The size of pages

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.ParticipantProgressRepeatingDataCollection.t/0` records.

# `list_repeating_data_progress!`

```elixir
@spec list_repeating_data_progress!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(
    CastorEDC.Model.ParticipantProgressRepeatingDataCollection.t()
  )
```

The same as `list_repeating_data_progress/4`, returning the result or raising `CastorEDC.Error`.

# `list_visit_progress`

```elixir
@spec list_visit_progress(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok,
   CastorEDC.Page.t(CastorEDC.Model.ParticipantProgressVisitCollection.t())}
  | {:error, CastorEDC.Error.t()}
```

Fetch visit progress per participant.

Sends `GET /api/study/{study_id}/participant-progress/{participant_id}/visit`. [API reference](https://data.castoredc.com/api#/participant-progress/get_study__study_id__participant_progress__participant_id__visit)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant for which to retrieve progress

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `100`; a larger one is lowered to it) - The size of pages

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.ParticipantProgressVisitCollection.t/0` records.

# `list_visit_progress!`

```elixir
@spec list_visit_progress!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.ParticipantProgressVisitCollection.t())
```

The same as `list_visit_progress/4`, returning the result or raising `CastorEDC.Error`.

# `stream_form_progress`

```elixir
@spec stream_form_progress(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.ParticipantProgress.t())
```

Streams every record `list_form_progress/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, in the API's default page size unless `:page_size` says
otherwise; see `CastorEDC.Pagination`.

# `stream_participants`

```elixir
@spec stream_participants(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.Participant.t())
```

Streams every record `list_participants/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_repeating_data_progress`

```elixir
@spec stream_repeating_data_progress(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.ParticipantProgressRepeatingDataCollection.t())
```

Streams every record `list_repeating_data_progress/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_visit_progress`

```elixir
@spec stream_visit_progress(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.ParticipantProgressVisitCollection.t())
```

Streams every record `list_visit_progress/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
