import os from "os"
import {promises as fs} from "fs"
import {sep, resolve as resolvePath} from "path"

import {flow} from "panda-garden"
import {toJSON, dashed} from "panda-parchment"
import {write, rmr} from "panda-quill"
import PandaTemplate from "panda-template"

import renderDocs from "./render"
import {safe_mkdir, gzip, brotli} from "../../utils"

T = new PandaTemplate()
T.handlebars().registerHelper
    dashed: (input) -> dashed input

# {{@root.root}}

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
  tmpDir = os.tmpdir()
  config.environment.temp = await fs.mkdtemp "#{tmpDir}#{sep}"
  config

writeAPIResources = (config) ->
  root = config.environment.temp
  await write (resolvePath root, "resources.json"), toJSON config.resources
  config

writeAPIDefinition = (config) ->
  root = config.environment.temp
  string = toJSON resources: config.resources

  path = resolvePath root, "api-definition"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), docIndexFile

  path = resolvePath root, "api-definition", "json"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  config


writeAPIDocs = (config) ->
  root = config.environment.temp
  string = renderDocs config

  path = resolvePath root, "api-definition", "html"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  config

writeHandlerIndex = (config) ->
  {resources} = config
  root = resolvePath "handlers"
  string = T.render indexTemplate, {resources, root}

  root = config.environment.temp
  await write (resolvePath "src", "handlers", "index.coffee"), string
  config


writeEnvironmentVariables = (config) ->
  root = config.environment.temp
  string = toJSON config.environment.dispatch.variables
  await write (resolvePath root, "env.json"), string
  config

writeVaultVariables = (config) ->
  root = config.environment.temp
  string = toJSON config.environment.dispatch.vault
  await write (resolvePath root, "vault.json"), string
  config


render = flow [
  setupTempDirectory
  writeAPIResources
  writeAPIDefinition
  writeAPIDocs
  writeHandlerIndex
  writeEnvironmentVariables
  writeVaultVariables
]

cleanup = (config) -> await rmr config.environment.temp

export {render, cleanup}
