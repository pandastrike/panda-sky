# This assembles the CloudFormation Description for core features of a Panda
# Sky deployment, the API Gateway and Lambdas that back it.

# Libraries
import {resolve, parse, relative} from "path"
import {merge} from "panda-parchment"
import {ls, lsR, read} from "panda-quill"
import {yaml} from "panda-serialize"

# Helper Classes
import Templater from "../templater"

# Paths
skyRoot = resolve __dirname, "..", "..", "..", ".."
tPath = (file) -> resolve skyRoot, "templates", "api-reference", file

registerPartials = (T) ->
  components = await ls tPath "partials"
  for c in components when parse(c).ext == ".pug"
    T.registerPartial(parse(c).name, await read c)

registerTemplate = (path) ->
  templater = await Templater.read path
  await registerPartials templater
  templater


render = (template, config) ->
  template.render config

renderReference = (config) ->
  template = tPath "reference.pug"
  # For this special template to produce a human-friendly API reference, strip out the "virtual" resources used to make API Gateway pathing behave.
  real = {}
  real[k] = v for k, v of config.resources when not /^virtual/.test k

  render (await registerTemplate template), (merge config, {resources: real})


export default renderReference
