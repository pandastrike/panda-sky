import Path from "path"
import fs from "fs"
import webpack from "webpack"

transpile = (config) ->
  new Promise (yay, nay) ->
    webpack
      entry: Path.resolve "src", "sky.coffee"
      mode: config.environment.webpack.mode
      devtool: "inline-source-map"
      target: "node"
      output:
        path: Path.resolve "lib"
        filename: "sky.js"
        libraryTarget: "umd"
        devtoolNamespace: config.name
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
                    node: config.environment.webpack.target
                ]]
          ]
        ,
          test: /\.js$/
          use: [ require.resolve "source-map-loader" ]
          enforce: "pre"
        ,
          test: /\.yaml$/
          use: [ require.resolve "yaml-loader" ]
        ,
          test: /^\.\/src.*\.json$/
          use: [ require.resolve "json-loader" ]
        ]
      resolve:
        alias:
          "-sky-api-definition": Path.resolve config.environment.temp,
            "api-definition"
          "-sky-api-resources": Path.resolve config.environment.temp,
            "resources.json"
          "-sky-api-handlers": Path.resolve "src", "handlers"
          "-sky-api-env": Path.resolve config.environment.temp,
            "env.json"
          "-sky-api-vault": Path.resolve config.environment.temp,
            "vault.json"
        modules: [
          "node_modules"
          "src/handlers"
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
        fs.writeFileSync "webpack-stats.json", JSON.stringify stats.toJson()
        yay()

export default transpile
