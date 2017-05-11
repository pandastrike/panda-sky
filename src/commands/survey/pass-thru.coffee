{createReadStream} = require "fs"
{go, map, tee, reject,
w, include, Type, isType, isMatch, Method,
glob} = require "fairmont"

{define, context} = require "panda-9000"
{save, render} = Asset = require "../../asset"
{pathWithUnderscore} = require "../../utils"

formats = w ".html .css .js .xml .json .yaml"

type = Type.define Asset

define "survey/pass-thru", ->
  try
    source = "src"
    go [
      glob "**/*{#{formats.join ','}}", source
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
  target.content = createReadStream source.path
