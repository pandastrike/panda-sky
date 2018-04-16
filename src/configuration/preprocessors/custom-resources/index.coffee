# There are some situations that require custom CloudFormation resources to do special things in our Sky stack.

{async} = require "fairmont"
# This is weird because lamdba-killer contains an npm package to run in lambda, but the code to setup the config is in a seperate file.
LambdaKiller = require "./lambda-killer/config"

module.exports = async (config) ->
  config = yield LambdaKiller config
  config
