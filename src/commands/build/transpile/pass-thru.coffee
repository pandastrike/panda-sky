import {createReadStream} from "fs"
import {resolve} from "path"
import {go, map, tee, reject, wait} from "panda-river"
import {include, w} from "panda-parchment"
import {Method} from "panda-generics"
import {glob, read} from "panda-quill"

import {pathWithUnderscore, context, write} from "../../../utils"

formats = w ".html .css .xml .json .yaml"

render = ({source, target}) ->
  target.content = createReadStream source.path

transpile = (sourceDir, targetDir) ->
  try
    await go [
      await glob "**/*{#{formats.join ','}}", sourceDir
      map context sourceDir
      tee ({source, target}) -> target.extension = source.extension
      tee render
      wait map (x) -> x
      tee write targetDir
    ]
  catch e
    console.error e.stack
    process.exit -1

export default transpile
