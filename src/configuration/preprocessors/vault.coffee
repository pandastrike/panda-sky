# Vault loads configuration secrets from AWS SecretsManager
check = (config) ->
  {name, env, profile} = config

  {read} = config.sundog.ASM()
  vault = {}
  for name in config.environment.dispatch.vault
     vault[name] = await read name

  config.environment.dispatch.vault = vault
  config

export default check
