import {createReadStream} from "fs"
import {go, map, tee, reject, w, include, Type, isType, isMatch, Method, glob} from "fairmont"
import {define, context} from "panda-9000"

import Asset from "../../asset"
{save, render} = Asset
import {pathWithUnderscore} from  "../../utils"

formats = w ".html .css .xml .json .yaml"

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
