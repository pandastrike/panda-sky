{async, read, merge } = require "fairmont"
JSCK = require "jsck"

Schemas = require "./schemas"

validator = Schemas.validator "api"

module.exports = class API

  constructor: (description) ->
    {valid, errors} = validator.validate description
    if not valid
      error = new Error "Invalid Sky API document"
      error.errors = errors
    {@resources, @schema, @variables} = description

