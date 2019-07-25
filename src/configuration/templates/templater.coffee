import {resolve as _resolve, parse} from "path"
import PandaTemplate from "panda-template"
import {curry, memoize} from "panda-garden"
import {first, rest, toJSON, equal, empty, dashed, camelCase, capitalize,
  plainText} from "panda-parchment"
import {read, glob} from "panda-quill"
import {yaml} from "panda-serialize"

resolve = (parts...) -> _resolve __dirname, "..", "..", "..", "..", "..",
  "templates", parts...

name = (path) -> parse(path).name

render = curry (T, config, path) ->
  T.render (await (memoize read) path), config

setup = (config) ->
  config.environment.templates ?= {}
  T = new PandaTemplate()
  T.handlebars().registerHelper
    yaml: (input) -> yaml input
    first: (input) -> first input
    rest: (input) -> rest input
    toJSON: (input) -> toJSON input
    equal: (A, B) -> A == B
    empty: (input) -> isEmpty input
    dashed: (input) -> dashed input
    camelCase: (input) -> camelCase input
    capitalize: (input) -> capitalize input
    templateCase: (input) -> capitalize camelCase plainText input

  {T, config}

registerPartials = (dir) ->
  ({T, config}) ->
    for path in await glob "**/*", dir
      T.registerPartial (name path), await read path
    {T, config}

export {resolve, name, render, setup, registerPartials}
