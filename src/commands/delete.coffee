import {first, sleep} from "panda-parchment"

import {bellChar} from "../utils"
import compile from "../configuration"
import {teardownStack} from "../virtual-resources"

Delete = (stopwatch, env, {profile}) ->
  try
    appRoot = process.cwd()
    config = await compile appRoot, env, profile

    console.log "Deleting Sky deployment..."
    await teardownStack config
    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

export default Delete
