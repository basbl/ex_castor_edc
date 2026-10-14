# `CastorEDC.Auth`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0-rc.1/lib/castor_edc/auth.ex#L1)

Gets and keeps access tokens for clients built from client credentials.

`CastorEDC.new/1` attaches this to every client it builds from a client
ID and secret, so nobody has to fetch a token by hand:

  * Before a request, it takes a token from `POST /oauth/token` with the
    client credentials grant, unless one is cached that's valid for at
    least another minute. Tokens last five hours, and the API issues no
    refresh token for this grant, so an expired one is simply replaced.
  * Tokens are cached per server and credentials (the client ID and a hash
    of the secret), so every process using the same credentials shares
    them, and a client with the right ID but another secret never gets
    another client's token. Two processes that miss the cache at the
    same moment may both fetch one, which is harmless: every token stays
    valid until it expires.
  * When the API answers 401 anyway, the cached token is dropped and the
    request sent once more with a new one.

A token request the API refuses becomes a `CastorEDC.Error`. Accounts
that sign in through SSO or Castor Identity get a 403 from the token
endpoint until they've logged in to the Castor EDC web application in
the last seven days; that error has `code: :login_required`.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
