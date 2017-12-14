# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import sky from "panda-sky-helpers"
{env, dispatch, method} = sky()

# Handlers
import descriptionGet from "./description/get"
import alphaGet from "./alpha/get"
import alphaPut from "./alpha/put"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-alpha-get": method alphaGet
  "#{env.fullName}-alpha-put": method alphaPut

export {API}
