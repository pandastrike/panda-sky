module.exports = (config, env) ->
  if config.aws.environments?[env]
    desired = config.aws.environments[env]

    if desired.hostnames
      {domain} = config.aws
      throw new Error "Domain not provided for custom URL creation." if !domain
      hostnames = []
      hostnames.push "#{name}.#{domain}" for name in desired.hostnames
      config.aws.hostnames = hostnames
      config.aws.cache = desired.cache || {}

  config
