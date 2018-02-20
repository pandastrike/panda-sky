{writeFileSync} = require "fs"
path = require "path"
{go, tee, pull, values, async, lift, shell, exists} = require "fairmont"
{define, write, run} = require "panda-9000"
rmrf = lift require "rimraf"

{render} = Asset = require "../asset"
{safe_mkdir, bellChar, outputDuration} = require "../utils"

START = 0
module.exports = async (start) ->
  START = start
  if yield exists ".babelrc"
    console.error ".babelrc file detected.  Disabling default asset pipeline."
    run "custom-build"
  else
    console.error "Preparing code..."
    run "build"

define "build", ["survey"], async -> yield build()
define "custom-build", ["custom-survey"], async -> yield build()

build = async ->
  try
    source = "src"
    target = "lib"
    manifest = "package.json"

    if !(yield exists manifest)
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit()

    # To ensure consistency, wipe out the build, node_module, and deploy dirs.
    console.error "  -- Wiping out build directories"
    yield rmrf "deploy"
    yield rmrf target
    yield rmrf "node_modules"
    yield safe_mkdir target

    # Pipeline the assets from "src" into an intermidate directory, lib.
    console.error "  -- Pipelining project code"
    yield go [
      Asset.iterator()
      tee async (formats) ->
        yield go [
          values formats
          tee render
          pull
          tee write target
        ]
      pull
    ]

    # Run npm install for the developer.  Only the stuff going into Lambda
    console.error "  -- Building deploy package"
    yield shell "npm install --only=production --silent"
    yield shell "cp -r node_modules/ #{target}/node_modules/" if yield exists "node_modules"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    yield safe_mkdir "deploy"
    yield shell "zip -qr -9 deploy/package.zip lib"

    # Now install everything, including dev-dependencies
    console.error "  -- Installing local dependencies"
    yield shell "npm install --silent"

    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.error bellChar
