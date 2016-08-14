{go, map, tee, reject, include, Type, isType, Method, glob} = require "fairmont"

{define, context, coffee} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"

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

Method.define render, (isType type), coffee
