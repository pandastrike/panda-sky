# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import {env, dispatch, method} from "panda-sky-helpers"

# Handlers
import descriptionGet from "./description/get"
import alphaGet from "./alpha/get"
import alphaPut from "./alpha/put"
import alphaDelete from "./alpha/delete"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-alpha-get": method alphaGet
  "#{env.fullName}-alpha-put": method alphaPut
  "#{env.fullName}-alpha-delete": method alphaDelete

export {API}
