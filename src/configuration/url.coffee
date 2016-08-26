module.exports = (config, env) ->
  desired = config.aws.environments[env]
  {domain} = config.aws

  hostnames = []
  hostnames.push "#{name}.#{domain}" for name in desired.hostnames
  hostnames.unshift domain  if env.apex == "primary"
  hostnames.push domain     if desired.apex == "secondary"
  config.aws.hostnames = hostnames

  config
