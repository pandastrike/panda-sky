{join} = require "path"
{define} = require "panda-9000"
{async} = require "fairmont"
{safe_cp, safe_mkdir} = require "./utils"

# This sets up an existing directory to hold a Panda Sky project.
define "init", async ->
  try
    # Drop in an API description stub.
    yield safe_cp join( __dirname, "../init/api.yaml"), join( process.cwd(), "api.yaml")

    # Drop in a Panda Sky configuration stub.
    yield safe_cp join( __dirname, "../init/sky.yaml"), join process.cwd(), "sky.yaml"

    # Drop in a handler stub.
    yield safe_mkdir join process.cwd(), "src"
    yield safe_cp join( __dirname, "../init/sky.js"), join process.cwd(), "src/sky.js"
    yield safe_cp join( __dirname, "../init/s3.js"), join process.cwd(), "src/s3.js"

    console.log "Panda Sky project initalized."
  catch e
    console.error e.stack
