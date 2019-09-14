# Vault loads configuration secrets from AWS SecretsManager
check = (config) ->
  config.environment.edge.vault ?= []
  {read} = config.sundog.ASM()

  vault = {}
  for name in config.environment.edge.vault
     vault[name] = await read name

  config.environment.edge.vault = vault
  config

export default check
