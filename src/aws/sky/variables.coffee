{join} = require "path"

module.exports = (env, config) ->
  s = {}
  s.env = env
  s.config = config
  s.stackName = "#{config.name}-#{env}"
  s.srcName = "#{config.name}-#{env}-#{config.projectID}"
  s.pkg = join process.cwd(), "deploy", "package.zip"
  s.apiDef = join process.cwd(), "api.yaml"
  s.skyDef = join process.cwd(), "sky.yaml"
  s.permissions = config.policyStatements
  s
