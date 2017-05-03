{writeFileSync} = require "fs"
path = require "path"
{go, tee, pull, values, async, lift, shell, exists, sleep} = require "fairmont"
{define, write} = require "panda-9000"
rmrf = lift require "rimraf"

{render} = Asset = require "./asset"
{safe_mkdir} = require "./utils"

define "build-update", ["survey"], async (cmd) ->
  try
    source = "src"
    target = "lib"
    manifest = "package.json"

    # Dump the processed assets from "src" into an intermidate directory, lib.
    yield go [
      Asset.iterator()
      tee async (formats) ->
        yield go [
          values formats
          tee render
          pull
          tee write target
        ]
    ]

    try
      yield sleep 100  # TODO: This is hacky, but the write isn't complete when we get here sometimes.
      yield shell cmd
    catch e
      console.error e

  catch e
    console.error e.stack
