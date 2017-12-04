# Set the environment variables that are injected into each Lambda.  Default
# variables are always injected so that the user's Lambda will know to what
# project it belongs.

# TODO: AWS provides default encryption to variables set here upon their upload
# but we should consider how to encrypt these client side so AWS never sees plaintext.

{merge} = require "fairmont"
Sky = require "../../../aws/sky/variables"
module.exports = (config) ->
  {env, aws:{environments}} = config
  sky = Sky env, config
  {variables} = environments[env]

  variables = {} if !variables
  variables = merge variables, {
    baseName: config.name
    environment: config.env
    projectID: config.projectID
    fullName: "#{config.name}-#{config.env}"
    skyBucket: sky.srcName  # Root bucket used to orchastrate Panda Sky state.
  }

  config.environmentVariables = variables
  config
