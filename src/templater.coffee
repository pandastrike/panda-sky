import {read} from "panda-quill"
import {first, rest, toJSON, empty, dashed, camelCase,
  capitalize} from "panda-parchment"
import {yaml} from "panda-serialize"
import PandaTemplate from "panda-template"

class Templater
  @read: (path) ->
    new Templater await read path

  constructor: (@template) ->
    @T = new PandaTemplate()
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

      yaml: (input) -> yaml input
      first: (input) -> first input
      rest: (input) -> rest input
      toJSON: (input) -> toJSON input
      equal: (A, B) -> A == B
      empty: (input) -> empty input
      dashed: (input) -> dashed input
      camelCase: (input) -> camelCase input
      capitalize: (input) -> capitalize input

  render: (config) -> @T.render @template, config

export default Templater
