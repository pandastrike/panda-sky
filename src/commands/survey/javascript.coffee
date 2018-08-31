import {go, map, tee, reject, read, w, include, Type, isType, Method,glob} from "fairmont"
import {resolve} from "path"
import {define, context} from "panda-9000"
import babel from "babel-core"

import Asset from "../../asset"
{save, render} = Asset
import {pathWithUnderscore} from "../../utils"

type = Type.define Asset

define "survey/javascript", ->
  try
    source = "src"
    go [
      glob "**/*.js", source
      reject pathWithUnderscore
      map context source
      tee ({source, target}) -> target.extension = source.extension
      map (context) -> include (Type.create type), context
      tee save
    ]
  catch e
    console.error e.stack
    process.exit()


Method.define render, (isType type), ({source, target}) ->
  # AWS Lambda runtimes only go up to Node v6.10.  Babel allows us to support more advanced JavaScript, like the ES6 standard.
  try
    source.content ?= await read source.path

    env = resolve __dirname, "..", "..", "..", "..", "..", "node_modules", "babel-preset-env"
    {code} = babel.transform source.content,
      sourceFileName: source.name + source.extension
      sourceMaps: "inline"
      presets: [[
        env,
        targets:
          node: "6.10"
      ]]

    target.content = code
  catch e
    console.error "Transpilation failure for #{source.path}"
    console.error e
    process.exit -1
