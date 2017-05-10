{async, read, merge } = require "fairmont"
{yaml} = require "panda-serialize"
JSCK = require "jsck"

Schemas = require "./schemas"

validator = Schemas.validator "api"

module.exports = class API

  @read: async (apiFile) ->
    new @ yaml yield read apiFile

  constructor: (description) ->
    {valid, errors} = validator.validate description
    if not valid
      error = new Error "Invalid Sky API document"
      error.errors = errors
    {@resources, @schema, @variables} = description

