# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
import {resolve, parse, relative} from "path"
import {merge, ls, lsR, read} from "fairmont"
import {yaml} from "panda-serialize"

# Helper Classes
import Templater from "../../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", "..", "..", ".."
tPath = (file) -> resolve skyRoot, "templates", file

registerPartials = (T) ->
  components = await ls tPath "partials"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, await read c)

registerTemplate = (path) ->
  templater = await Templater.read path
  await registerPartials templater
  templater

render = (template, config) ->
  template.render config

nameKey = (path) -> relative (resolve skyRoot, "templates", "stacks"), path

renderCore = (config) ->
  core = {}
  stacks = await lsR tPath "stacks/core"
  for s in stacks when parse(s).ext == ".yaml"
    core[nameKey s] = render (await registerTemplate s), config
  core

renderTopLevel = (config) ->
  render (await registerTemplate tPath "top-level.yaml"), config


export {renderCore, renderTopLevel}
