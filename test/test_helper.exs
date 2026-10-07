# Mix tasks report through Mix.shell/0; send that output to the test process.
Mix.shell(Mix.Shell.Process)

ExUnit.start()
