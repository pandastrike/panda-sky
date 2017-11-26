JSCK = require "jsck"
{async, read, merge } = require "fairmont"
{yaml} = require "panda-serialize"
pandaTemplate = require("panda-template").default

module.exports = class Templater
  constructor: (@template, @schema) ->
    @validator = new JSCK.draft4 @schema
    @T = new pandaTemplate()

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

  registerPartial: (name, template) ->
    console.error name, template
    @T.registerPartial name, template

  render: (config) ->
    @validate config
    @T.render @template, config

  validate: (config) ->
    {valid, errors} = @validator.validate config
    if not valid
      if @schema.title?
        message = "Invalid config for template: '#{@schema.title}'"
      else
        message = "Invalid config for template"
      error = new Error message
      error.errors = errors
      throw error
    config
