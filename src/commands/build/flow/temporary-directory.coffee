import os from "os"
import {promises as fs} from "fs"
import {sep, resolve as resolvePath} from "path"

import {flow} from "panda-garden"
import {toJSON, dashed} from "panda-parchment"
import {mkdirp, write, rmr} from "panda-quill"
import PandaTemplate from "panda-template"

import renderDocs from "./render"
import {gzip, brotli} from "../../../utils"

T = new PandaTemplate()
T.handlebars().registerHelper
    dashed: (input) -> dashed input

indexTemplate = """
handlers = do ->
  {{#each resources}}
  "{{dashed @key}}":
    {{#each methods}}
    {{@key}}: (await require "./{{dashed @../key}}/{{@key}}.coffee").default
    {{/each}}
  {{/each}}

export default handlers
"""

wrap = (string) -> """
  export default \"\"\"
  #{string}
  \"\"\"
  """

encodingIndexFile =  """
import identity from "./identity"
import gzip from "./gzip"
import br from "./brotli"

out = {identity, gzip, br}
export default out
"""

docIndexFile =  """
import json from "./json"
import html from "./html"

out =
  "application/json": json
  "text/html": html

export default out
"""

setupTempDirectory = (config) ->
  console.log "establishing temporary directory"
  tmpDir = os.tmpdir()
  config.environment.temp = await fs.mkdtemp "#{tmpDir}#{sep}"
  config

setupSubdirectories = (config) ->
  root = config.environment.temp
  await mkdirp "0777", resolvePath root, "main"

  for name of config.environment.workers
    await mkdirp "0777", resolvePath root, "workers", name

  # for name of config.environment.cache.edge
  #   await mkdirp "0777", resolvePath root, "edge"
  config

writeHandlerIndex = (config) ->
  console.log "writing handler manifest"
  {resources} = config
  root = resolvePath "handlers"
  string = T.render indexTemplate, {resources, root}

  await write (resolvePath "src", "handlers", "index.coffee"), string
  config

writeAPIResources = (config) ->
  console.log "formatting API resources data"
  root = config.environment.temp
  await write (resolvePath root, "resources.json"), toJSON config.resources
  config

writeAPIDefinition = (config) ->
  root = config.environment.temp
  string = toJSON resources: config.resources

  path = resolvePath root, "api-definition"
  await mkdirp "0777", path
  await write (resolvePath path, "index.coffee"), docIndexFile

  path = resolvePath root, "api-definition", "json"
  await mkdirp "0777", path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  config


writeAPIDocs = (config) ->
  console.log "formatting API docs"
  root = config.environment.temp
  string = renderDocs config

  path = resolvePath root, "api-definition", "html"
  await mkdirp "0777", path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  config

writeEnvironmentVariables = (config) ->
  console.log "establishing environment variables"
  root = config.environment.temp

  # API environment variables
  await write (resolvePath root, "main", "env.json"),
    toJSON config.environment.dispatch.variables

  # Worker environment variables
  for name, worker of config.environment.workers
    await write (resolvePath root, "workers", name, "env.json"),
      toJSON worker.lambda.variables

  # Edge lambda environment variables
  # string = toJSON config.environment.dispatch.variables
  # await write (resolvePath root, "main", "env.json"), string
  config

writeVaultVariables = (config) ->
  console.log "establishing environment secrets"
  root = config.environment.temp

  # API vault
  await write (resolvePath root, "main", "vault.json"),
    toJSON config.environment.dispatch.vault

  # Worker vaults
  for name, worker of config.environment.workers
    await write (resolvePath root, "workers", name, "vault.json"),
      toJSON worker.vault

  # Edge lambda vaults
  # await write (resolvePath root, "main", "vault.json"),
  #   toJSON config.environment.dispatch.vault
  config


setup = flow [
  setupTempDirectory
  setupSubdirectories
  writeHandlerIndex
  writeAPIResources
  writeAPIDefinition
  writeAPIDocs
  writeEnvironmentVariables
  writeVaultVariables
]

cleanup = (config) ->
  console.log "removing temporary directory data"
  await rmr config.environment.temp
  config

export {setup, cleanup}
