import {toJSON} from "panda-parchment"
import {exists, rmr} from "panda-quill"

import {safe_mkdir, bellChar, outputDuration, shell} from "../../utils"
import compile from "../../configuration"
import build from "./flow"

START = 0
Build = (env, {profile}) ->
  try
    if !(await exists "package.json")
      console.error "This project does not yet have a package.json. Run 'npm
        init' to initialize the project and then make sure all dependencies
        are listed."
      process.exit -1

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.log "Wiping out build directories"
    await rmr "deploy"
    await rmr "build"

    console.log "Installing dependencies..."
    await shell "npm install"

    console.log "Compiling environment configuration..."
    config = await compile process.cwd(), env, profile

    console.log "Packaging API code..."
    await build config
  catch e
    console.error e.stack
  console.info bellChar
  config

export default Build
