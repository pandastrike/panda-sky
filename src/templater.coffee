import JSCK from "jsck"
import {read} from "panda-quill"
import {merge, collect, project} from "panda-parchment"
import {yaml} from "panda-serialize"
import pandaTemplate from "panda-template"

join = (d, array) -> array.join d

Templater = class Templater
  constructor: (@template, @schema) ->
    @validator = new JSCK.draft4 @schema
    @T = new pandaTemplate()
    @T.handlebars().registerHelper
      # Specially modified version of "each" that maps a dictionary to an array using an explicit index.  The index is off by one because the root resource always goes first.
      orderedEach: (context, options) ->
        trueContext = []
        for key, value of context
          trueContext[value.index - 1] = value

        ret = ""
        for c in trueContext
          ret = ret + options.fn c
        ret

  @read: (templatePath, schemaPath) ->
    template = await read templatePath
    if schemaPath
      schema = yaml await read schemaPath
    else
      schema =
        $schema: "http://json-schema.org/draft-04/schema#"
        type: "object"
        minProperties: 1

    new @ template, schema

  registerPartial: (name, template) ->
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

export default Templater
