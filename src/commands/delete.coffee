import {first, sleep} from "panda-parchment"

import {bellChar} from "../utils"
import compile from "../configuration"
import Stack from "../virtual-resources/stack"

Delete = (stopwatch, env, {profile}) ->
  try
    appRoot = process.cwd()
    config = await compile appRoot, env, profile
    stack = await Stack config

    console.log "Deleting Sky deployment..."
    await stack.delete()
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

export default Delete
