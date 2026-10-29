# `CastorEDC.Roles`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/roles.ex#L4)

The roles of a study.

## Operations

  * `create_role/4` - Creates a role
  * `get_role/4` - Retrieve a single Role
  * `list_roles/3` - A list of roles related to the Study.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `create_role`

```elixir
@spec create_role(CastorEDC.client(), String.t(), map(), keyword()) ::
  {:ok, CastorEDC.Model.Role.t()} | {:error, CastorEDC.Error.t()}
```

Creates a role.

Creates `Role` object.

Sends `POST /api/study/{study_id}/role`. [API reference](https://data.castoredc.com/api#/role/post_study__study_id__role)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `body` - a map, sent as JSON: Role to add
    * `name` (string, required) - Role name
    * `description` (string) - Role description
    * `permissions` (object)

Every option is passed to `Req`.

# `create_role!`

```elixir
@spec create_role!(CastorEDC.client(), String.t(), map(), keyword()) ::
  CastorEDC.Model.Role.t()
```

The same as `create_role/4`, returning the result or raising `CastorEDC.Error`.

# `get_role`

```elixir
@spec get_role(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.Role.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single Role.

Sends `GET /api/study/{study_id}/role/{role_name}`. [API reference](https://data.castoredc.com/api#/role/get_study__study_id__role__role_name_)

## Arguments

  * `study_id` - The ID of the study for which this call should be made
  * `role_name` - Role name

Every option is passed to `Req`.

# `get_role!`

```elixir
@spec get_role!(CastorEDC.client(), String.t(), String.t(), keyword()) ::
  CastorEDC.Model.Role.t()
```

The same as `get_role/4`, returning the result or raising `CastorEDC.Error`.

# `list_roles`

```elixir
@spec list_roles(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.Role.t())}
  | {:error, CastorEDC.Error.t()}
```

A list of roles related to the Study.

Sends `GET /api/study/{study_id}/role`. [API reference](https://data.castoredc.com/api#/role/get_study__study_id__role)

## Arguments

  * `study_id` - The ID of the study for which this call should be made

Every option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.Role.t/0` records.

# `list_roles!`

```elixir
@spec list_roles!(CastorEDC.client(), String.t(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.Role.t())
```

The same as `list_roles/3`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
