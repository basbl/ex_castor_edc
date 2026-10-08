# Contributing

## Setup

The Erlang and Elixir versions are pinned in `.tool-versions`; with [asdf](https://asdf-vm.com) or [mise](https://mise.jdx.dev), `asdf install` or `mise install` installs them.

```console
$ mix deps.get
$ lefthook install
```

[lefthook](https://lefthook.dev) installs a pre-commit hook that runs `mix precommit`, so every commit is compiled, formatted, linted and tested before it's made.

## Checks

```console
$ mix precommit   # compile with warnings as errors, drop unused lock entries, format, Credo, tests
$ mix quality     # dependency audits, format check, Credo, Dialyzer, docs with warnings as errors
$ mix coveralls   # tests with coverage, failing below the threshold in coveralls.json
```

CI runs `mix compile --warnings-as-errors`, `mix coveralls` and `mix quality`.

## Commits

Each commit is one logical change that leaves the build green.

- `mix precommit` passes on every commit, not just at the tip of a branch, so `git bisect` and reverts always work.
- Tooling, mechanical changes, behaviour changes and deletions go in separate commits.
  The exception is adopting a formatter plugin, which goes in one commit with the reformat it causes.
- A commit that adds behaviour includes its tests.
- A change to `priv/openapi/overlay.yaml` or to the generator includes the rebuilt `priv/openapi/castor_edc.json` and the regenerated client (`mix castor_edc.spec.build` and `mix castor_edc.gen.client`); `mix quality` fails when they're out of date.
- Replacements happen in three steps: add the new thing beside the old, move callers over, then delete the old one.
- A user-visible or breaking change updates `CHANGELOG.md` in the commit that makes it.
- Messages are imperative and in sentence case, without a prefix (`Add pagination stream`), with a body explaining why when the subject doesn't.
- Pull requests are merged without squashing, so the individual commits survive.
