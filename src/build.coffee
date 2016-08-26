{writeFileSync} = require "fs"
{go, tee, pull, values, async, lift, shell, exists} = require "fairmont"
{define, write} = require "panda-9000"
rmrf = lift require "rimraf"
AdmZip = require 'adm-zip'

{render} = Asset = require "./asset"
{safe_mkdir} = require "./utils"

define "build", ["survey"], async ->
  try
    if !yield exists "package.json"
      console.error "This project does not yet have a package.json. \nRun 'npm
        init' to initialize the project \nand then make sure all dependencies
        are listed."
      process.exit()

    # Dump the processed assets from "src" into an intermidate directory, lib.
    yield rmrf "deploy"
    source = "src"
    target = "lib"

    yield rmrf target

    yield go [
      Asset.iterator()
      tee async (formats) ->
        yield go [
          values formats
          tee render
          pull
          tee write target
        ]
    ]

    # Run npm install for the developer.
    yield shell "npm install"

    # Package up the lib and node_modules dirs into a ZIP archive for AWS.
    zip = new AdmZip()
    zip.addLocalFolder "lib", "lib"
    if yield exists "node_modules"
      zip.addLocalFolder "node_modules", "node_modules"
    yield safe_mkdir "deploy"
    zip.writeZip "deploy/package.zip"

  catch e
    console.error e.stack
