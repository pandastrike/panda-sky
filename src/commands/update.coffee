import {join} from "path"
import {define, write, run} from "panda-9000"
import {yaml} from "panda-serialize"
import {go, tee, pull, values, shell, exists} from "fairmont"

import {bellChar, outputDuration} from "../utils"
import configuration from "../configuration"
import Asset from "../asset"
{render} = Asset

START = 0
Update = (start, env, {profile}) ->
  START = start
  console.log "Updating #{env}..."
  run "update", [env, profile]

define "update", ["survey"], (env, profile) ->
  try
    appRoot = process.cwd()
    config = await configuration.compile(appRoot, env, profile)
    sky = await require("../aws/sky")(env, config)

    # Push code through asset pipeline.
    source = "src"
    target = "lib"
    pkg = "deploy/package.zip"

    fail() if !await exists join process.cwd(), pkg

    await go [
      Asset.iterator()
      tee (formats) ->
        await go [
          values formats
          tee render
          pull
          tee write target
        ]
      pull
    ]

    # Push code into pre-existing Zip archive.
    await shell "zip -qr -9 #{pkg} lib -x *node_modules*"

    # Update Sky metadata with new Zip acrhive, and republish all lambdas.
    await sky.lambdas.update()
    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.info bellChar

fail = ->
  console.error "WARNING: Unable to find project Zip archive.  This suggests that the project has never been through the 'sky build' step.  `sky update` is only meant to be used for pre-existing deployments."
  console.log "Done."
  process.exit()

export default Update
