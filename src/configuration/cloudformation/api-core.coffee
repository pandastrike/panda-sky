# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
{resolve, parse, relative} = require "path"
{async, merge, ls, lsR, read} = require "fairmont"
{yaml} = require "panda-serialize"

# Helper Classes
Templater = require "../../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", ".."
tPath = (file) -> resolve skyRoot, "templates", file

registerPartials = async (T) ->
  components = yield ls tPath "partials"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, yield read c)

registerTemplate = async (path) ->
  templater = yield Templater.read path
  yield registerPartials templater
  templater

render = (template, config) ->
  template.render config

nameKey = (path) -> relative (resolve skyRoot, "templates", "stacks"), path

renderCore = async (config) ->
  core = {}
  stacks = yield lsR tPath "stacks/core"
  for s in stacks when parse(s).ext == ".yaml"
    core[nameKey s] = render (yield registerTemplate s), config
  core

renderTopLevel = async (config) ->
  yaml render (yield registerTemplate tPath "top-level.yaml"), config


module.exports = {renderCore, renderTopLevel}
