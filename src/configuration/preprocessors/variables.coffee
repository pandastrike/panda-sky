# Set the environment variables that are injected into each Lambda.  Default
# variables are always injected so that the user's Lambda will know to what
# project it belongs.

# TODO: AWS provides default encryption to variables set here upon their upload
# but we should consider how to encrypt these client side so AWS never sees plaintext.

# We also want to gather configuration that's used in the "stack" resource used to orchestarte the deployment.

import {join} from "path"
import {merge} from "fairmont"

applyStackVariables = (config) ->
    config.aws.stack =
      name: "#{config.name}-#{config.env}"
      src: "#{config.name}-#{config.env}-#{config.projectID}"
      pkg: join process.cwd(), "deploy", "package.zip"
      apiDef: join process.cwd(), "api.yaml"
      skyDef: join process.cwd(), "sky.yaml"
    config

applyEnvironmentVariables = (config) ->
  {env, aws:{environments}} = config
  {variables} = environments[env]

  variables = {} if !variables
  variables = merge variables,
    baseName: config.name
    environment: config.env
    projectID: config.projectID
    fullName: config.aws.stack.name

    # Root bucket used to orchastrate Panda Sky state.
    skyBucket: config.aws.stack.src

  config.environmentVariables = variables
  config

Variables = (config) ->
  config = applyStackVariables config
  config = applyEnvironmentVariables config
  config

export default Variables
