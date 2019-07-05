import {resolve as _resolve, parse, relative} from "path"
import {merge} from "panda-parchment"
import {glob, read} from "panda-quill"
import {yaml} from "panda-serialize"

import PandaTemplate from "panda-template"

T = new PandaTemplate()
@T.handlebars().registerHelper
  yaml: (input) -> yaml input

resolve = (parts...) -> _resolve __dirname, "..", "..", "..", "..",
  "templates", parts...

nameFile = (path) -> parse(path).name

render = (paths..., config) ->
  yaml T.render (await read resolve paths...), config


registerPartials = (T) ->
  components = await ls tPath "partials"
  for c in components when parse(c).ext == ".yaml"
    T.registerPartial(parse(c).name, await read c)

registerTemplate = (path) ->
  templater = await Templater.read path
  await registerPartials templater
  templater

render = (template, config) ->
  T.render template, config

nameKey = (path) -> relative (resolve skyRoot, "templates", "stacks"), path

renderCore = (config) ->
  core = {}
  stacks = await lsR tPath "stacks/core"
  for s in stacks when parse(s).ext == ".yaml"
    core[nameKey s] = render (await registerTemplate s), config
  core

# This needs to be output as an object because we identify an intermediate template using this base in the stack's orchestration model.
renderTopLevel = (config) ->
  yaml render (await registerTemplate tPath "top-level.yaml"), config


Render = (config) ->

  for path in await glob "**/*.yaml", resolve "main", "partials"
    T.registerPartial (nameFile path), await read c

  config.environment.templates =
    main:
      root: render "main", "root.yaml", config



  config.environment.templates.core = await go [
    glob "**/*.yaml", resolve "templates", "stacks", "core"
  ]
    map
  ]


export default Render
