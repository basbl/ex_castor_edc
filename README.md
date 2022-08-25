# ExCastorEDC

[![Package](https://img.shields.io/hexpm/v/ex_castor_edc.svg)](https://hex.pm/packages/ex_castor_edc) [![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/ex_castor_edc) ![CI](https://github.com/basbl/ex_castor_edc/actions/workflows/ci.yml/badge.svg)

An unofficial Elixir wrapper for the [Castor EDC API](https://data.castoredc.com/api).

Not all endpoints have been implemented yet, these will be gradually added in future releases.

## Getting started

In order to use `ex_castor_edc`, you will need Elixir installed. Then create an
Elixir project via the `mix` build tool:

```
$ mix new my_app
```

Then you can add `ex_castor_edc` as dependency in your `mix.exs`.

```elixir
def deps do
  [
    {:ex_castor_edc, "~> 0.3.0"}
  ]
end
```

Alternatively, inside a script or Livebook:

```elixir
Mix.install([
  {:ex_castor_edc, "~> 0.3.0"}
])
```
