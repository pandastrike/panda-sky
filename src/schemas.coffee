import {resolve} from "path"
import fs from "fs"

import {read} from "panda-quill"
import {merge} from "panda-parchment"
import {yaml} from "panda-serialize"
import JSCK from "jsck"

schemaRoot = resolve __dirname, "..", "..", "..", "schema"

cache = {}

validator = (name) ->
  if (v = cache[name])?
    v
  else
    schemaFile = resolve schemaRoot, "#{name}.yaml"
    data = yaml fs.readFileSync schemaFile, "utf-8"
    cache[name] = new JSCK.draft4 data

export default {
  validator
}
