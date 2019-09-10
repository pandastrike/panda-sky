# Vault loads configuration secrets from AWS SecretsManager
check = (config) ->
  config.environment.worker.vault ?= []
  {read} = config.sundog.ASM()

  vault = {}
  for name in config.environment.worker.vault
     vault[name] = await read name

  config.environment.worker.vault = vault
  config

export default check
