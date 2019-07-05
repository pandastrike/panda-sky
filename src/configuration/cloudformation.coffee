import {resolve as _resolve, parse} from "path"
import {flow, wrap, curry, ternary} from "panda-garden"
import {include, first, pairs} from "panda-parchment"
import {map, reduce} from "panda-river"
import {glob, read} from "panda-quill"
import {yaml} from "panda-serialize"

import PandaTemplate from "panda-template"

resolve = (parts...) -> _resolve __dirname, "..", "..", "..", "..",
  "templates", parts...

name = (path) -> parse(path).name

render = curry ternary (T, config, path) ->
  "#{name path}": T.render (await read path), config

renderDir = (T, config, dir) ->
  await do flow [
    wrap glob "**/*.yaml", dir
    map render T, config
    reduce include, {}
  ]

setup = (config) ->
  T = new PandaTemplate()
  {T, config}

registerHelpers = ({T, config}) ->
  T.handlebars().registerHelper
    yaml: (input) -> yaml input
  {T, config}

registerPartials = ({T, config}) ->
  for path in await glob "**/*.yaml", resolve "main", "partials"
    T.registerPartial (name path), await read path
  {T, config}

renderCore = ({T, config}) ->
  config.environment.templates = include {},
    await render T, config, resolve "main", "root.yaml"
    core: await renderDir T, config, resolve "main", "core"
  {T, config}

addMixins = ({config}) ->
  config.environment.templates.mixins = await do flow [
    wrap pairs config.environment.mixins
    map ([_name, {template}]) ->
      if template then "#{_name}": template else {}
    reduce include, {}
  ]

  config

Render = flow [
  setup
  registerHelpers
  registerPartials
  renderCore
  addMixins
]

export default Render
