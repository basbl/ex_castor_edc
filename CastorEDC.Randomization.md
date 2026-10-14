# `CastorEDC.Randomization`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/randomization.ex#L4)

Randomizing participants and reading their randomization.

## Operations

  * `get_randomization/4` - Retrieve a single RandomizationDetails
  * `randomize_participant/4` - Randomize a participant

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_randomization`

```elixir
@spec get_randomization(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.RandomizationDetails.t()}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a single RandomizationDetails.

Sends `GET /api/study/{study_id}/participant/{participant_id}/randomization`. [API reference](https://data.castoredc.com/api#/randomization/get_study__study_id__participant__participant_id__randomization)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - Participant ID of the RandomizationDetails to fetch

Every option is passed to `Req`.

# `get_randomization!`

```elixir
@spec get_randomization!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.RandomizationDetails.t()
```

The same as `get_randomization/4`, returning the result or raising `CastorEDC.Error`.

# `randomize_participant`

```elixir
@spec randomize_participant(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.RandomizationDetails.t()}
  | {:error, CastorEDC.Error.t()}
```

Randomize a participant.

Randomize a participant if possible.

Sends `POST /api/study/{study_id}/participant/{participant_id}/randomization`. [API reference](https://data.castoredc.com/api#/randomization/post_study__study_id__participant__participant_id__randomization)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `participant_id` - Participant ID of the RandomizationDetails to fetch

Every option is passed to `Req`.

# `randomize_participant!`

```elixir
@spec randomize_participant!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.RandomizationDetails.t()
```

The same as `randomize_participant/4`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
