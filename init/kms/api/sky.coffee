# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import {env, dispatch, method} from "panda-sky-helpers"

# Handlers
import descriptionGet from "./description/get"
import randomGet from "./random/get"
import encryptPut from "./encrypt/put"
import decryptPut from "./decrypt/put"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-random-get": method randomGet
  "#{env.fullName}-encrypt-put": method encryptPut
  "#{env.fullName}-decrypt-put": method decryptPut

export {API}
