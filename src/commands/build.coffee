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

    # Dump the processed assets from "src" into an intermidate directory, lib.
    yield rmrf "deploy"
    yield rmrf target
    yield safe_mkdir target

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

    # Run npm install for the developer.
    yield shell "npm install --production --silent"
    yield shell "cp -r node_modules/ #{target}/node_modules/" if yield exists "node_modules"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    yield safe_mkdir "deploy"
    yield shell "zip -qr deploy/package.zip lib"

    console.error "Done. (#{outputDuration START})\n\n"
  catch e
    console.error e.stack
  console.error bellChar
