import {go, map, tee, reject, include, Type, isType, Method, glob, read} from "fairmont"
import {resolve} from "path"

import {define, context} from "panda-9000"
import coffee from "coffeescript"
import "babel-preset-env"
import Asset from "../../asset"
{save, render} = Asset
import {pathWithUnderscore} from "../../utils"

type = Type.define Asset

define "survey/coffee", ->
  try
    source = "src"
    go [
      glob "**/*.coffee", source
      reject pathWithUnderscore
      map context source
      tee ({target}) -> target.extension = ".js"
      map (context) -> include (Type.create type), context
      tee save
    ]
  catch e
    console.error e.stack
    process.exit()

Method.define render, (isType type), ({source, target}) ->
  # Though we support CSv2+, for now we need to run this code in a Lambda that
  # can only go up to Nodev6.10.  Babel allows us to transpile to a safe target.
  try
    source.content ?= await read source.path

    env = resolve __dirname, "..", "..", "..", "..", "..", "node_modules", "babel-preset-env"
    target.content = coffee.compile source.content,
      filename: source.name + source.extension
      inlineMap: true
      transpile:
        presets: [[
          env,
          targets:
            node: "6.10"
        ]]

  catch e
    console.error "Transpilation failure for #{source.path}"
    console.error e
    process.exit -1
