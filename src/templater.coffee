JSCK = require "jsck"
{async, read, merge } = require "fairmont"
{yaml} = require "panda-serialize"
pandatemplate = require "panda-template"

module.exports = class Templater
  @read: async (templatePath, schemaPath) ->
    template = yield read templatePath
    if schemaPath
      schema = yaml yield read schemaPath
    else
      schema =
        $schema: "http://json-schema.org/draft-04/schema#"
        type: "object"
        minProperties: 1

    new @ template, schema

  constructor: (@template, @schema) ->
    @validator = new JSCK.draft4 @schema

  render: (config) ->
    {valid, errors} = @validator.validate config
    if not valid
      if @schema.title?
        message = "Invalid config for template: '#{@schema.title}'"
      else
        message = "Invalid config for template"
      error = new Error message
      error.errors = errors
      throw error

    pandatemplate @template, config




#template = yield read resolve "templates", "api.yaml"
#yaml _render template, mungedConfig
