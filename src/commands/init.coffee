{join} = require "path"
{define} = require "panda-9000"
{async, randomWords, read, write, shell} = require "fairmont"
_render = require "panda-template"
{safe_cp, safe_mkdir} = require "../utils"
interview = require "../interview"

# This sets up an existing directory to hold a Panda Sky project.
define "init", async ->
  try
    # Ask politely to install fairmont and js-yaml
    # TODO: fold the parts of these that we use in the Lambdas into wrapper
    #     to be intorduced in beta-02
    interview.setup()
    questions = [
      name: "ps"
      description: "Add panda-sky as a dependency to package.json? [Y/n]"
      default: "Y"
    ,
      name: "yaml"
      description: "Add js-yaml as a dependency to package.json? [Y/n]"
      default: "Y"
    ]

    console.log "Press ^C at any time to quit."
    answers = yield interview.ask questions

    if answers.fairmont || answers.yaml
      console.log "\n Adding module(s). One moment..."
      yield shell "npm install panda-sky --save" if answers.ps
      yield shell "npm install js-yaml --save" if answers.yaml



    config =
      projectID: yield randomWords 6

    # Drop in the file stubs.
    src = (file) -> join( __dirname, ".../init/#{file}")
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

    console.log "Panda Sky project initialized."
  catch e
    console.error e.stack
