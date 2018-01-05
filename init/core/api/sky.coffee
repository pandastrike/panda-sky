# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import {env, dispatch, method} from "panda-sky-helpers"
 
# Handlers
import descriptionGet from "./description/get"
import greetingGet from "./greeting/get"
import homeGet from "./home/get"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-greeting-get": method greetingGet
  "#{env.fullName}-home-get": method homeGet

export {API}
