import {merge} from "panda-parchment"
import {read} from "panda-quill"
import {yaml} from "panda-serialize"
import JSCK from "jsck"

import Schemas from "../schemas"

validator = Schemas.validator "api-description"

API = class API

  @read: (apiPath) ->
    # TODO: allow either a yaml file or a directory of yaml files
    new @ yaml await read apiPath

  constructor: (description) ->
    {valid, errors} = validator.validate description
    if not valid
      console.error errors
      throw new Error "Invalid Panda Sky API Description"
    {@resources, @schema, @variables} = description

export default API
