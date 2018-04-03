{join} = require "path"
{define, write, run} = require "panda-9000"
{yaml} = require "panda-serialize"
{async, go, tee, pull, values, shell, exists} = require "fairmont"

{bellChar, outputDuration} = require "../utils"
configuration = require "../configuration"
{render} = Asset = require "../asset"

START = 0
module.exports = (start, env, {profile}) ->
  START = start
  console.error "Updating #{env}..."
  run "update", [env, profile]

define "update", ["survey"], async (env, profile) ->
  try
    appRoot = process.cwd()
    config = yield configuration.compile(appRoot, env, profile)
    sky = yield require("../aws/sky")(env, config)

    # Push code through asset pipeline.
    source = "src"
    target = "lib"
    pkg = "deploy/package.zip"

    fail() if !yield exists join process.cwd(), pkg

    yield go [
      Asset.iterator()
      tee async (formats) ->
        yield go [
          values formats
          tee render
          pull
          tee write target
        ]
      pull
    ]

    # Push code into pre-existing Zip archive.
    yield shell "zip -qr -9 #{pkg} lib -x *node_modules*"

    # Update Sky metadata with new Zip acrhive, and republish all lambdas.
    yield sky.lambdas.update()
    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.error bellChar

fail = ->
  console.error """
  WARNING: Unable to find project Zip archive.  This suggests that the project has never been through the 'sky build' step.  `sky update` is only meant to be used for pre-existing deployments.

  Done.
  """
  process.exit()
