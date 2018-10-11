import {join} from "path"
import {exists} from "panda-quill"
import {shell} from "fairmont"

import {bellChar} from "../utils"
import transpile from "./build/transpile"
import configuration from "../configuration"
import Handlers from "../virtual-resources/handlers"

Update = (stopwatch, env, {profile}) ->
  console.log "Updating #{env}..."
  try
    appRoot = process.cwd()
    config = await configuration.compile(appRoot, env, profile)
    handlers = await Handlers config

    # Push code through asset pipeline.
    source = "src"
    target = "lib"
    pkg = "deploy/package.zip"

    fail() if !await exists join process.cwd(), pkg
    await transpile source, target

    # Push code into pre-existing Zip archive.
    await shell "zip -qr -9 #{pkg} lib -x *node_modules*"

    # Update Sky metadata with new Zip acrhive, and republish all lambdas.
    await handlers.update()
    console.log "Done. (#{stopewatch()})"
  catch e
    console.error e.stack
  console.info bellChar

fail = ->
  console.error "WARNING: Unable to find project Zip archive.  This suggests that the project has never been through the 'sky build' step.  `sky update` is only meant to be used for pre-existing deployments."
  console.log "Done."
  process.exit()

export default Update
