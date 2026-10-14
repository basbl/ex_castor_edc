# `CastorEDC.RepeatingData`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/repeating_data.ex#L4)

Repeating data: its definitions and forms, and the instances created for participants.

## Operations

  * `create_repeating_data_instance/5` - Creates a repeating data instance.
  * `create_repeating_data_instances/5` - Creates a collection of repeating data instances.
  * `get_participant_repeating_data_instance/5` - Retrieve a single repeating data instance
  * `get_repeating_data/4` - Retrieve a single Repeating Data
  * `get_repeating_data_form/5` - Retrieve a single RepeatingDataForm
  * `get_repeating_data_instance/4` - Retrieve a single repeating data instance
  * `list_participant_repeating_data_instances/4` - Retrieve list of available repeating data instances
  * `list_repeating_data/3` - Retrieve list of available Repeating Data
  * `list_repeating_data_forms/4` - Retrieve list of available RepeatingDataForms of one specific Repeating Data
  * `list_repeating_data_instances/3` - Retrieve list of available repeating data instances

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_repeating_data_instance`

```elixir
@spec create_repeating_data_instance(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  {:ok, CastorEDC.Model.RepeatingDataInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Creates a repeating data instance.

Creates an instance of Repeating Data for a specific Participant. Repeating Data Instances are the objects on which data points are
stored and are required to be created before that happens. They can have a custom name that has to be unique within
a given participant.

Repeating Data Instances can have a parent defined to create a tree-like structure of parent/child information elements. Parents
can be either a visit or another repeating data instance and have to be defined with parent_type and parent_id.

To store data on repeated measures repeating data, the parent_type and parent_id should always point to the visit or
repeating data instance on which the repeated measure field is present.

Sends `POST /api/study/{study_id}/participant/{participant_id}/repeating-data-instance`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/post_study__study_id__participant__participant_id__repeating_data_instance)

## Arguments

  * `study_id` - The ID of the study to create a repeating data instance for
  * `participant_id` - The ID of the participant to create a repeating data instance for
  * `body` - a map, sent as JSON: Repeating Data Instance details to create the object.
    * `repeating_data_id` (string, required) - The identifier of the repeating data that should be instantiated in this repeating data instance
    * `repeating_data_name_custom` (string, required) - The name of the repeating data instance. Must be unique within the given participant.
    * `parent_id` (string) - Identifier of the visit or repeating data instance to attach the new repeating data instance to.

Every option is passed to `Req`.

# `create_repeating_data_instance!`

```elixir
@spec create_repeating_data_instance!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.RepeatingDataInstance.t()
```

The same as `create_repeating_data_instance/5`, returning the result or raising `CastorEDC.Error`.

# `create_repeating_data_instances`

```elixir
@spec create_repeating_data_instances(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  {:ok, CastorEDC.Model.RepeatingDataInstanceCollection.t()}
  | {:error, CastorEDC.Error.t()}
```

Creates a collection of repeating data instances.

Creates a collection of repeating data instances for a specific participant. Repeating data instances are the objects on which data points are
stored and are required to be created before that happens. They can have a custom name that has to be unique within
a given participant.

Repeating data instances can have a parent defined to create a tree-like structure of parent/child information elements. Parents
can be either a visit or another repeating data instance and have to be defined with parent_type and parent_id.

To store data on repeated measures repeating data, the parent_type and parent_id should always point to the visit or
repeating data instance on which the repeated measure field is present.

Sends `POST /api/study/{study_id}/participant/{participant_id}/repeating-data-instance-collection`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/post_study__study_id__participant__participant_id__repeating_data_instance_collection)

## Arguments

  * `study_id` - The ID of the study to create the repeating data instances for
  * `participant_id` - The ID of the participant to create the repeating data instances for
  * `body` - a map, sent as JSON: Repeating data instance collection data with the details to create them.
    * `data` (list of map, required)
      * `repeating_data_id` (string, required) - The identifier of the repeating data that should be instantiated in this repeating data instance
      * `repeating_data_name_custom` (string, required) - The name of the repeating data instance. Must be unique within the given participant.
      * `parent_id` (string) - Identifier of the visit or repeating data instance to attach the new repeating data instance to.

Every option is passed to `Req`.

Returns what was saved and what wasn't; the `!` variant raises a `CastorEDC.Error` when anything wasn't.

# `create_repeating_data_instances!`

```elixir
@spec create_repeating_data_instances!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  map(),
  keyword()
) ::
  CastorEDC.Model.RepeatingDataInstanceCollection.t()
```

The same as `create_repeating_data_instances/5`, returning the result or raising `CastorEDC.Error`.

# `get_participant_repeating_data_instance`

```elixir
@spec get_participant_repeating_data_instance(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.RepeatingDataInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a single repeating data instance.

Sends `GET /api/study/{study_id}/participant/{participant_id}/repeating-data-instance/{repeating_data_instance_id}`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__participant__participant_id__repeating_data_instance__repeating_data_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant
  * `repeating_data_instance_id` - Repeating Data Instance ID to fetch

Every option is passed to `Req`.

# `get_participant_repeating_data_instance!`

```elixir
@spec get_participant_repeating_data_instance!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) :: CastorEDC.Model.RepeatingDataInstance.t()
```

The same as `get_participant_repeating_data_instance/5`, returning the result or raising `CastorEDC.Error`.

# `get_repeating_data`

```elixir
@spec get_repeating_data(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.RepeatingData.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Repeating Data.

Sends `GET /api/study/{study_id}/repeating-data/{repeating_data_id}`. [API reference](https://data.castoredc.com/api#/repeating-data/get_study__study_id__repeating_data__repeating_data_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `repeating_data_id` - The ID of the repeating data for which this call should be made

Every option is passed to `Req`.

# `get_repeating_data!`

```elixir
@spec get_repeating_data!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.RepeatingData.t()
```

The same as `get_repeating_data/4`, returning the result or raising `CastorEDC.Error`.

# `get_repeating_data_form`

```elixir
@spec get_repeating_data_form(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.RepeatingDataForm.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single RepeatingDataForm.

Sends `GET /api/study/{study_id}/repeating-data/{repeating_data_id}/repeating-data-form/{repeating_data_form_id}`. [API reference](https://data.castoredc.com/api#/repeating-data-form/get_study__study_id__repeating_data__repeating_data_id__repeating_data_form__repeating_data_form_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `repeating_data_id` - The ID of the repeating data for which this call should be made
  * `repeating_data_form_id` - ID of the RepeatingDataForm to fetch

Every option is passed to `Req`.

# `get_repeating_data_form!`

```elixir
@spec get_repeating_data_form!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Model.RepeatingDataForm.t()
```

The same as `get_repeating_data_form/5`, returning the result or raising `CastorEDC.Error`.

# `get_repeating_data_instance`

```elixir
@spec get_repeating_data_instance(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Model.RepeatingDataInstance.t()}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a single repeating data instance.

Sends `GET /api/study/{study_id}/repeating-data-instance/{repeating_data_instance_id}`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__repeating_data_instance__repeating_data_instance_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `repeating_data_instance_id` - Repeating Data Instance ID to fetch

Every option is passed to `Req`.

# `get_repeating_data_instance!`

```elixir
@spec get_repeating_data_instance!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Model.RepeatingDataInstance.t()
```

The same as `get_repeating_data_instance/4`, returning the result or raising `CastorEDC.Error`.

# `list_participant_repeating_data_instances`

```elixir
@spec list_participant_repeating_data_instances(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.RepeatingDataInstance.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available repeating data instances.

Gets `RepeatingDataPackageInstance` objects, which are 'instantiations' of Repeating Data.
The Repeating Data Instance is the entity to which the data gets saved.

Sends `GET /api/study/{study_id}/participant/{participant_id}/repeating-data-instance`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__participant__participant_id__repeating_data_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - The ID of the participant to retrieve repeating data instances for

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:archived` (boolean) - `true` for only archived repeating data instances, `false` (what the API does when it's left out) for only unarchived ones.
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.RepeatingDataInstance.t/0` records.

# `list_participant_repeating_data_instances!`

```elixir
@spec list_participant_repeating_data_instances!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.RepeatingDataInstance.t())
```

The same as `list_participant_repeating_data_instances/4`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data`

```elixir
@spec list_repeating_data(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.RepeatingData.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available Repeating Data.

Gets `RepeatingData` objects. Repeating Datas are used for repeating measurements or events, that have a 1::N
relationship with the Participant.

Sends `GET /api/study/{study_id}/repeating-data`. [API reference](https://data.castoredc.com/api#/repeating-data/get_study__study_id__repeating_data)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.RepeatingData.t/0` records.

# `list_repeating_data!`

```elixir
@spec list_repeating_data!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.RepeatingData.t())
```

The same as `list_repeating_data/3`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data_forms`

```elixir
@spec list_repeating_data_forms(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.RepeatingDataForm.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available RepeatingDataForms of one specific Repeating Data.

Gets `RepeatingDataForm` objects, which are Forms that are collected only once per Repeating Data.
RepeatingDataForms are placed in a Repeating Data and contain Fields.

Sends `GET /api/study/{study_id}/repeating-data/{repeating_data_id}/repeating-data-form`. [API reference](https://data.castoredc.com/api#/repeating-data-form/get_study__study_id__repeating_data__repeating_data_id__repeating_data_form)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `repeating_data_id` - The ID of the repeating data for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.RepeatingDataForm.t/0` records.

# `list_repeating_data_forms!`

```elixir
@spec list_repeating_data_forms!(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  CastorEDC.Page.t(CastorEDC.Model.RepeatingDataForm.t())
```

The same as `list_repeating_data_forms/4`, returning the result or raising `CastorEDC.Error`.

# `list_repeating_data_instances`

```elixir
@spec list_repeating_data_instances(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.RepeatingDataInstance.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve list of available repeating data instances.

Gets `RepeatingDataPackageInstance` objects, which are 'instantiations' of Repeating Data.
The Repeating Data Instance is the entity to which the data gets saved.

Sends `GET /api/study/{study_id}/repeating-data-instance`. [API reference](https://data.castoredc.com/api#/repeating-data-instance/get_study__study_id__repeating_data_instance)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

## Options

  * `:page` (integer, defaults to `1`) - The page to retrieve
  * `:archived` (boolean) - `true` for only archived repeating data instances, `false` (what the API does when it's left out) for only unarchived ones.
  * `:page_size` (integer, at most `1000`; a larger one is lowered to it) - The number of records per page.

Any other option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.RepeatingDataInstance.t/0` records.

# `list_repeating_data_instances!`

```elixir
@spec list_repeating_data_instances!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.RepeatingDataInstance.t())
```

The same as `list_repeating_data_instances/3`, returning the result or raising `CastorEDC.Error`.

# `stream_participant_repeating_data_instances`

```elixir
@spec stream_participant_repeating_data_instances(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.RepeatingDataInstance.t())
```

Streams every record `list_participant_repeating_data_instances/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_repeating_data`

```elixir
@spec stream_repeating_data(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.RepeatingData.t())
```

Streams every record `list_repeating_data/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_repeating_data_forms`

```elixir
@spec stream_repeating_data_forms(
  CastorEDC.client(),
  String.t(),
  String.t(),
  keyword()
) ::
  Enumerable.t(CastorEDC.Model.RepeatingDataForm.t())
```

Streams every record `list_repeating_data_forms/4` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

# `stream_repeating_data_instances`

```elixir
@spec stream_repeating_data_instances(CastorEDC.client(), String.t(), keyword()) ::
  Enumerable.t(CastorEDC.Model.RepeatingDataInstance.t())
```

Streams every record `list_repeating_data_instances/3` pages through.

Takes the same arguments and options. Pages are fetched as the stream is
consumed, as large as the API allows unless `:page_size` says otherwise;
see `CastorEDC.Pagination`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
