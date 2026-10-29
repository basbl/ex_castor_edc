# `CastorEDC.Users`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/users.ex#L4)

The users the credentials can see.

## Operations

  * `get_user/3` - Retrieve a single User
  * `list_users/2` - Retrieve a list of users the currently authenticated user is authorized to see. Default to own User.

Every operation returns `{:ok, result}` or `{:error, %CastorEDC.Error{}}`,
and has a `!` variant that returns the result or raises the error.

# `get_user`

```elixir
@spec get_user(CastorEDC.client(), String.t(), keyword()) ::
  {:ok, CastorEDC.Model.User.t()} | {:error, CastorEDC.Error.t()}
```

Retrieve a single User.

Sends `GET /api/user/{user_id}`. [API reference](https://data.castoredc.com/api#/user/get_user__user_id_)

## Arguments

  * `user_id` - The ID of the user to retrieve

Every option is passed to `Req`.

# `get_user!`

```elixir
@spec get_user!(CastorEDC.client(), String.t(), keyword()) :: CastorEDC.Model.User.t()
```

The same as `get_user/3`, returning the result or raising `CastorEDC.Error`.

# `list_users`

```elixir
@spec list_users(CastorEDC.client(), keyword()) ::
  {:ok, CastorEDC.Page.t(CastorEDC.Model.User.t())}
  | {:error, CastorEDC.Error.t()}
```

Retrieve a list of users the currently authenticated user is authorized to see. Default to own User.

Sends `GET /api/user`. [API reference](https://data.castoredc.com/api#/user/get_user)

Every option is passed to `Req`.

Returns a `CastorEDC.Page` of `t:CastorEDC.Model.User.t/0` records.

# `list_users!`

```elixir
@spec list_users!(CastorEDC.client(), keyword()) ::
  CastorEDC.Page.t(CastorEDC.Model.User.t())
```

The same as `list_users/2`, returning the result or raising `CastorEDC.Error`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
