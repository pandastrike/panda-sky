import {resolve} from "path"
import {exists} from "panda-quill"

import {bellChar, shell} from "../utils"
#import transpile from "./build/transpile"
import compile from "../configuration"
import {syncLambdas, syncLambdaCode} from "../virtual-resources"

import build from "./build"

Update = (stopwatch, env, {profile, hard}) ->
  console.log "Updating #{env}..."
  try
    config = await build env, {profile}

    # Update Sky metadata with new Zip acrhive, and republish all lambdas.
    if hard
      await syncLambdas config
    else
      await syncLambdaCode config

    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

fail = ->
  console.error "WARNING: Unable to find project Zip archive.  This suggests that the project has never been through the 'sky build' step.  `sky update` is only meant to be used for pre-existing deployments."
  console.log "Done."
  process.exit()

export default Update
