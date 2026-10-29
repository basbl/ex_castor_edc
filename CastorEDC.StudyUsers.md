# `CastorEDC.StudyUsers`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/study_users.ex#L4)

The users of a study, and their roles per site.

## Operations

  * `add_study_user/4` - Add a user to the study.
  * `get_study_user/4` - Retrieve a single user, including their assigned roles per site.
  * `list_study_users/3` - Retrieve a list of users who have access to the study, including their assigned roles per site.
  * `remove_study_user/4` - Removes a user from the study.
  * `update_study_user/5` - Replace a single user's role assignments.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `add_study_user`

```elixir
@spec add_study_user(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.InvitationSuccess.t()} | {:error, CastorEDC.Error.t()}
```

Add a user to the study.

Sends `POST /api/study/{study_id}/user`. [API reference](https://data.castoredc.com/api#/study-user/post_study__study_id__user)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `body` - a map, sent as JSON
    * `default_role_assignment` (integer)
    * `email` (string)
    * `manage_permissions` (`t:CastorEDC.Model.ManagementPermissions.t/0`)
    * `message` (string)
    * `role_assignments` (list of map)
      * `role_name` (string)
      * `site_id` (string)
    * `send_invite_email` (boolean)

Every option is passed to `Req`.

# `add_study_user!`

```elixir
@spec add_study_user!(CastorEDC.client(), String.t(), map(), keyword()) ::
  CastorEDC.Model.InvitationSuccess.t()
```

The same as `add_study_user/4`, returning the result or raising `CastorEDC.Error`.

# `get_study_user`

```elixir
@spec get_study_user(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.StudyUser.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single user, including their assigned roles per site.

Sends `GET /api/study/{study_id}/user/{user_id}`. [API reference](https://data.castoredc.com/api#/study-user/get_study__study_id__user__user_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `user_id` - The ID of the user to retrieve

Every option is passed to `Req`.

# `get_study_user!`

```elixir
@spec get_study_user!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.StudyUser.t()
```

The same as `get_study_user/4`, returning the result or raising `CastorEDC.Error`.

# `list_study_users`

```elixir
@spec list_study_users(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.StudyUser.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a list of users who have access to the study, including their assigned roles per site.

Sends `GET /api/study/{study_id}/user`. [API reference](https://data.castoredc.com/api#/study-user/get_study__study_id__user)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

Every option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.StudyUser.t/0` records.

# `list_study_users!`

```elixir
@spec list_study_users!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.StudyUser.t())
```

The same as `list_study_users/3`, returning the result or raising `CastorEDC.Error`.

# `remove_study_user`

```elixir
@spec remove_study_user(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, term()} | {:error, CastorEDC.Error.t()}
```

Removes a user from the study.

Sends `DELETE /api/study/{study_id}/user/{user_id}`. [API reference](https://data.castoredc.com/api#/study-user/delete_study__study_id__user__user_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `user_id` - The ID of the user to remove

Every option is passed to `Req`.

# `remove_study_user!`

```elixir
@spec remove_study_user!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  term()
```

The same as `remove_study_user/4`, returning the result or raising `CastorEDC.Error`.

# `update_study_user`

```elixir
@spec update_study_user(CastorEDC.client(), String.t(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.RoleAssignmentUpdateSuccess.t()}
  | {:error, CastorEDC.Error.t()}
```

Replace a single user's role assignments.

Removes all of a users permissions and replaces them with the provided payload.

Sends `PUT /api/study/{study_id}/user/{user_id}`. [API reference](https://data.castoredc.com/api#/study-user/put_study__study_id__user__user_id_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `user_id` - The ID of the user to update
  * `body` - a map, sent as JSON
    * `default_role_assignment` (integer)
    * `manage_permissions` (`t:CastorEDC.Model.ManagementPermissions.t/0`)
    * `role_assignments` (list of map)
      * `role_name` (string)
      * `site_id` (string)

Every option is passed to `Req`.

# `update_study_user!`

```elixir
@spec update_study_user!(CastorEDC.client(), String.t(), String.t(), map(), keyword()) ::
  CastorEDC.Model.RoleAssignmentUpdateSuccess.t()
```

The same as `update_study_user/5`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
