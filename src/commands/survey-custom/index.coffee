import {go, map, tee, reject, read, w, include, Type, isType, Method, glob} from "fairmont"

import {join} from "path"
import {define, context} from "panda-9000"
import babel from "babel-core"

import Asset from "../../asset"
{save, render} = Asset

type = Type.define Asset

define "custom-survey", ->
  try
    source = "src"
    go [
      glob "**/*", source
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

    {code} = babel.transform source.content,
      sourceFileName: source.name + source.extension
      extends: join process.cwd(), ".babelrc"

    target.content = code
  catch e
    console.error "Transpilation failure for #{source.path}"
    console.error e
    process.exit -1
