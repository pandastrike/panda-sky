{async, go, map, tee, reject, read,
w, include, Type, isType, Method,
glob} = require "fairmont"

{join} = require "path"
{define, context} = require "panda-9000"
babel = require "babel-core"

{save, render} = Asset = require "../../asset"
{pathWithUnderscore} = require "../../utils"

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


Method.define render, (isType type), async ({source, target}) ->
  # AWS Lambda runtimes only go up to Node v6.10.  Babel allows us to support more advanced JavaScript, like the ES6 standard.
  try
    source.content ?= yield read source.path

    env = join __dirname, "..", "..", "..", "node_modules", "babel-preset-env"
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
