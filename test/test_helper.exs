# Mix tasks report through Mix.shell/0; send that output to the test process.
Mix.shell(Mix.Shell.Process)

# End-to-end tests talk to a real test study; run them with
# `mix test --only e2e` (see CastorEDC.E2ECase).
ExUnit.start(exclude: [:e2e])
