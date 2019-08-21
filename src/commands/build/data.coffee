import os from "os"
import {promises as fs} from "fs"
import {sep, resolve as resolvePath} from "path"

import {toJSON} from "panda-parchment"
import {write, rmr} from "panda-quill"

import renderDocs from "./render"
import {safe_mkdir, gzip, brotli} from "../../utils"

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

# Creates a temporary directory to store API definition and documentation in
# a variety of compression formats.
render = (config) ->
  string = toJSON resources: config.resources

  tmpDir = os.tmpdir()
  config.environment.temp = root = await fs.mkdtemp "#{tmpDir}#{sep}"

  await write (resolvePath root, "resources.json"), toJSON config.resources

  path = resolvePath root, "api-definition"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), docIndexFile

  path = resolvePath root, "api-definition", "json"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  console.log "Packaging API documentation..."
  string = renderDocs config

  path = resolvePath root, "api-definition", "html"
  await safe_mkdir path
  await write (resolvePath path, "index.coffee"), encodingIndexFile
  await write (resolvePath path, "identity.coffee"), wrap string
  await write (resolvePath path, "gzip.coffee"), wrap await gzip string
  await write (resolvePath path, "brotli.coffee"), wrap await brotli string

  config

cleanup = (config) -> await rmr config.environment.temp

export {render, cleanup}
