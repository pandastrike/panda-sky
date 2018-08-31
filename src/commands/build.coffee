import {go, tee, pull, values, lift, shell, exists} from "fairmont"
import {define, write, run} from "panda-9000"
import rimraf from "rimraf"
rmrf = lift rimraf

import Asset from "../asset"
{render} = Asset
import {safe_mkdir, bellChar, outputDuration} from "../utils"

START = 0
Build = (start) ->
  START = start
  if await exists ".babelrc"
    console.warn ".babelrc file detected.  Disabling default asset pipeline."
    run "custom-build"
  else
    console.log "Preparing code..."
    run "build"

define "build", ["survey"], -> await build()
define "custom-build", ["custom-survey"], -> await build()

build = ->
  try
    source = "src"
    target = "lib"
    manifest = "package.json"

    if !(await exists manifest)
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit()

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.log "  -- Wiping out build directories"
    await rmrf "deploy"
    await rmrf target
    await rmrf "node_modules"
    await rmrf "package-lock.json"
    await safe_mkdir target

    # Pipeline the assets from "src" into an intermidate directory, lib.
    console.log "  -- Pipelining project code"
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

    # Run npm install for the developer.  Only the stuff going into Lambda
    console.log "  -- Building deploy package"
    await shell "npm install --only=production --silent"
    await shell "cp -r node_modules/ #{target}/node_modules/" if await exists "node_modules"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    await safe_mkdir "deploy"
    await shell "zip -qr -9 deploy/package.zip lib"

    # Now install everything, including dev-dependencies
    console.log "  -- Installing local dependencies"
    await shell "npm install --silent"

    console.log "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.info bellChar

export default Build
