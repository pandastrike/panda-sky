import {toJSON} from "panda-parchment"
import {exists} from "panda-quill"

import {safe_mkdir, bellChar, outputDuration, shell} from "../../utils"
import compile from "../../configuration"

import {render, cleanup} from "./data"
import transpile from "./webpack"

START = 0
Build = (env, {profile}) ->
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
    console.log "Wiping out build directories"
    await shell "rm -rf deploy #{target}"

    console.log "Installing dependencies..."
    await shell "npm install"

    console.log "Compiling environment configuration..."
    config = await compile process.cwd(), env, profile

    # console.log "Packaging environment variables..."
    # await write "#{source}/-data/env.json",
    #   toJSON config.environment.dispatch.variables

    console.log "Packaging API definition and documentation..."
    config = await render config

    console.log "Webpacking project code..."
    await safe_mkdir target
    await transpile config

    # AWS Lambda requires a ZIP archive.
    console.log "Compressing final deploy package..."
    await safe_mkdir "deploy"
    await shell "zip -r -9 deploy/package.zip lib"

    console.log "Cleanup..."
    await cleanup config
  catch e
    console.error e.stack
  console.info bellChar
  config

export default Build
