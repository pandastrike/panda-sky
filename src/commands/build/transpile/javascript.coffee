import {resolve} from "path"
import {go, map, tee, reject, wait} from "panda-river"
import {include} from "panda-parchment"
import {Method} from "panda-generics"
import {glob, read} from "panda-quill"

import babel from "babel-core"
import "@babel/preset-env"
import {pathWithUnderscore, context, write} from "../../../utils"

render = ({source, target}) ->
  # AWS Lambda runtimes only go up to Node v6.10.  Babel allows us to support more advanced JavaScript, like the ES6 standard.
  try
    source.content ?= await read source.path

    env = resolve __dirname, "..", "..", "..", "..", "..", "..", "node_modules", "@babel/preset-env"
    {code} = babel.transform source.content,
      sourceFileName: source.name + source.extension
      sourceMaps: "inline"
      presets: [[
        env,
        targets:
          node: "8.10"
      ]]

    target.content = code

  catch e
    console.error "Transpilation failure for #{source.path}"
    console.error e
    process.exit -1

transpile = (sourceDir, targetDir) ->
  try
    await go [
      await glob "**/*.js", sourceDir
      map context sourceDir
      tee ({target}) -> target.extension = ".js"
      tee render
      wait
      tee write targetDir
    ]
  catch e
    console.error e.stack
    process.exit -1

export default transpile
