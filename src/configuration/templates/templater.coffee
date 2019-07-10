import {resolve as _resolve, parse} from "path"
import PandaTemplate from "panda-template"
import {curry, memoize} from "panda-garden"
import {first, capitalize, camelCase, plaintext} from "panda-parchment"
import {read, glob} from "panda-quill"
import {yaml} from "panda-serialize"

resolve = (parts...) -> _resolve __dirname, "..", "..", "..", "..",
  "templates", parts...

name = (path) -> parse(path).name

render = curry (T, config, path) ->
  "#{name path}": T.render (await memoize read path), config

setup = (config) ->
  config.environment.templates ?= {}
  T = new PandaTemplate()
  T.handlebars().registerHelper
    yaml: (input) -> yaml input
    templateCase: (input) -> capitalize camelCase plaintext input
  {T, config}

registerPartials = (dir) ->
  ({T, config}) ->
    for path in await glob "**/*", dir
      T.registerPartial (name path), await read path
    {T, config}

export {resolve, name, render, setup, registerPartials}
