{async, read, merge } = require "fairmont"
{yaml} = require "panda-serialize"
JSCK = require "jsck"

Schemas = require "../schemas"

validator = Schemas.validator "api-description"

module.exports = class API

  @read: async (apiPath) ->
    # TODO: allow either a yaml file or a directory of yaml files
    new @ yaml yield read apiPath

  constructor: (description) ->
    {valid, errors} = validator.validate description
    if not valid
      console.error errors
      throw new Error "Invalid Panda Sky API Description"
    {@resources, @schema, @variables} = description
