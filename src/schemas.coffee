{resolve} = require "path"
fs = require "fs"

{async, read, merge } = require "fairmont"
{yaml} = require "panda-serialize"
JSCK = require "jsck"

schemaRoot = resolve __dirname, "..", "..", "..", "schema"

cache = {}

validator = (name) ->
  if (v = cache[name])?
    v
  else
    schemaFile = resolve schemaRoot, "#{name}.yaml"
    data = yaml fs.readFileSync schemaFile, "utf-8"
    cache[name] = new JSCK.draft4 data

module.exports = {
  validator
}
