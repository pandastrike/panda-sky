import {resolve} from "path"
import {go, map, tee, reject, wait} from "panda-river"
import {include} from "panda-parchment"
import {Method} from "panda-generics"
import {glob, read} from "panda-quill"

import coffee from "coffeescript"
import "@babel/preset-env"
import {pathWithUnderscore, context, write} from "../../../utils"

render = ({source, target}) ->
  # Though we support CSv2+, for now we need to run this code in a Lambda that
  # can only go up to Nodev8.10.  Babel allows us to transpile to a safe target.
  try
    source.content ?= await read source.path

    env = resolve __dirname, "..", "..", "..", "..", "..", "..", "node_modules", "@babel/preset-env"
    target.content = coffee.compile source.content,
      filename: source.name + source.extension
      inlineMap: true
      transpile:
        presets: [[
          env,
          targets:
            node: "8.10"
        ]]

  catch e
    console.error "Transpilation failure for #{source.path}"
    console.error e
    process.exit -1

transpile = (sourceDir, targetDir) ->
  try
    await go [
      await glob "**/*.coffee", sourceDir
      map context sourceDir
      tee ({target}) -> target.extension = ".js"
      tee render
      wait map (x) -> x
      tee write targetDir
    ]
  catch e
    console.error e.stack
    process.exit -1

export default transpile
