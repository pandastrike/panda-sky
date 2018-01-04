# TODO - Sky's roadmap includes plans to automate the construction of this dispatcher.

# Access the Panda Sky dispatch helpers.
import sky from "panda-sky-helpers"
{env, dispatch, method} = sky()

# Handlers
import descriptionGet from "./description/get"
import initPost from "./init/post"
import playerGet from "./player/get"
import playerPut from "./player/put"
import playerDelete from "./player/delete"
import gameGet from "./game/get"

API = dispatch
  "#{env.fullName}-discovery-get": method descriptionGet
  "#{env.fullName}-init-post": method initPost
  "#{env.fullName}-player-get": method playerGet
  "#{env.fullName}-player-put": method playerPut
  "#{env.fullName}-player-delete": method playerDelete
  "#{env.fullName}-game-get": method gameGet


export {API}
