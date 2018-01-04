# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import sky from "panda-sky-helpers"
{env, dispatch, method} = sky()

# Handlers
import descriptionGet from "./description/get"
import greetingGet from "./greeting/get"
import homeGet from "./home/get"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-greeting-get": method greetingGet
  "#{env.fullName}-home-get": method homeGet

export {API}
