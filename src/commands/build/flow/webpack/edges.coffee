import Path from "path"
import fs from "fs"
import webpack from "webpack"
import {dashed} from "panda-parchment"
import {sharedDirectory} from "./helpers"

transpile = (config) ->

  for name, edge of config.environment.cache.edges
    console.log "Bundling Edge #{name}..."

    await new Promise (yay, nay) ->
      webpack
        entry: Path.resolve "edges", name, "src", "index.coffee"
        mode: edge.webpack.mode
        devtool: "inline-source-map"
        target: "node"
        output:
          path: Path.resolve "build", "edges", name
          filename: "index.js"
          libraryTarget: "umd"
          devtoolNamespace: dashed "#{config.name} edge.#{name}"
          devtoolModuleFilenameTemplate: (info, args...) ->
            {namespace, resourcePath} = info
            "webpack://#{namespace}/#{resourcePath}"

        externals: /^aws-sdk.*$/

        module:
          rules: [
            test: /\.coffee$/
            use: [
              loader: require.resolve "coffee-loader"
              options:
                transpile:
                  presets: [[
                    (require.resolve "@babel/preset-env"),
                    targets:
                      node: edge.webpack.target
                  ]]
            ]
          ,
            test: /\.js$/
            use: [ require.resolve "source-map-loader" ]
            enforce: "pre"
          ,
            test: /\.yaml$/
            type: "json"
            use: [ require.resolve "yaml-loader" ]
          ,
            test: /^\.\/src.*\.json$/
            use: [ require.resolve "json-loader" ]
          ]
        resolve:
          alias:
            "-sky-api-resources": Path.resolve config.environment.temp,
              "resources.json"
            "-sky-env": Path.resolve config.environment.temp,
              "edges", name, "env.json"
            "-sky-vault": Path.resolve config.environment.temp,
              "edges", name, "vault.json"
            "-shared": sharedDirectory()
          modules: [
            "node_modules"
          ]
          extensions: [ ".js", ".json", ".coffee" ]
        plugins: [

        ]
        (err, stats) ->
          if err?
            console.error err.stack || err
            console.error err.details if err.details
            nay new Error "Error during webpack build."

          info = stats.toString colors: true

          if stats.hasErrors()
            console.error info.errors
            nay new Error "Error during webpack build."

          if stats.hasWarnings()
            console.warn info.warnings

          console.log info
          yay config

  config

export default transpile
