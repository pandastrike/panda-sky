{join} = require "path"
{define} = require "panda-9000"
{async, randomWords, read, write} = require "fairmont"
_render = require "panda-template"
{safe_cp, safe_mkdir} = require "./utils"

# This sets up an existing directory to hold a Panda Sky project.
define "init", async ->
  try
    config =
      projectID: yield randomWords 6
    src = (file) -> join( __dirname, "../init/#{file}")
    target = (file) -> join process.cwd(), file

    render = async (src, target) ->
      template = yield read src
      output = _render template, config
      yield write target, output

    # Drop in an API description stub.
    yield safe_cp (src "api.yaml"), (target "api.yaml")

    # Drop in a Panda Sky configuration stub.
    yield render (src "sky.yaml"), (target "sky.yaml")

    # Drop in a handler stub.
    yield safe_mkdir target "src"
    yield render (src "sky.js"), (target "src/sky.js")
    yield render (src "s3.js"), (target "src/s3.js")

    console.log "Panda Sky project initalized."
  catch e
    console.error e.stack
