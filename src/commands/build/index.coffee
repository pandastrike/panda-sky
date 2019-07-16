import {go, tee, pull} from "panda-river"
import {values} from "panda-parchment"
import {exists, write, read} from "panda-quill"
import {yaml} from "panda-serialize"
import pug from "pug"

import transpile from "./transpile"
import {safe_mkdir, bellChar, outputDuration, shell} from "../../utils"
import compile from "../../configuration"


START = 0
Build = (stopwatch, env, {profile}) ->
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
    console.log "    -- Pulling production dependencies..."
    await shell "npm install --only=production --silent"
    await shell "cp -r node_modules/ #{target}/node_modules/" if await exists "node_modules"

    # Now install everything, including dev-dependencies
    console.log "    -- Pulling local dependencies..."
    await shell "npm install --silent"

    console.log "    -- Applying environment configuration..."
    console.log "        - Copying API definition..."
    {resources} = yaml await read "api.yaml"
    await write "#{target}/api.yaml", yaml {resources}

    console.log "        - Rendering API documentation..."
    config = await compile process.cwd(), env, profile
    await write "#{target}/api.html",
      pug.render config.environment.templates.apiDocs

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    console.log "    -- Compressing final deploy package..."
    await safe_mkdir "deploy"
    await shell "zip -qr -9 deploy/package.zip lib"

    console.log "Done. (#{stopwatch()})"
  catch e
    console.error e.stack
  console.info bellChar

export default Build
