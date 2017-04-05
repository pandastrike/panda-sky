# Accept a configuration for the deployment and come up with tags for every
# resrouce we label within the stack.
module.exports = (config, env) ->
  tags = [
    {
      Key: "project"
      Value: config.name
    }
    {
      Key: "skyID"
      Value: config.projectID
    }
    {
      Key: "environment"
      Value: env
    }
  ]

  if config.tags
    tags.push(tag) for tag in config.tags
  config.tags = tags
  config
