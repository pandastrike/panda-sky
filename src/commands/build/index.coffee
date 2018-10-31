import {go, tee, pull} from "panda-river"
import {values} from "panda-parchment"
import {exists} from "panda-quill"
import {shell} from "fairmont"

import transpile from "./transpile"
import {safe_mkdir, bellChar, outputDuration} from "../../utils"

START = 0
Build = (stopwatch) ->
  console.log "Preparing code..."

  try
    source = "src"
    target = "lib"
    manifest = "package.json"

    if !(await exists manifest)
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit -1

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.log "  -- Wiping out build directories"
    await shell "rm -rf deploy #{target} node_modules package-lock.json"

    console.log "  -- Pipelining project code"
    await safe_mkdir target
    await transpile source, target


    # Run npm install for the developer.  Only the stuff going into Lambda
    console.log "  -- Building deploy package"
    await shell "npm install --only=production --silent"
    await shell "cp -r node_modules/ #{target}/node_modules/" if await exists "node_modules"
    await shell "cp api.yaml #{target}/api.yaml"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    await safe_mkdir "deploy"
    await shell "zip -qr -9 deploy/package.zip lib"

    # Now install everything, including dev-dependencies
    console.log "  -- Installing local dependencies"
    await shell "npm install --silent"

    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

export default Build
