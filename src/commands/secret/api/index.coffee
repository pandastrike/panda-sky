import {resolve} from "path"
import {merge} from "panda-parchment"
import {confidential} from "panda-confidential"
import {yaml} from "panda-serialize"
import {read} from "panda-quill"
import {startConfig, readSky} from "../../../configuration/validate"
import {validate, getSDK} from "../../../configuration/preprocessors/environment"

{randomBytes, convert} = confidential()

start = (env, {profile}) ->
  startConfig process.cwd(), env, profile

generate = (context) ->
  {name} = yaml await read resolve process.cwd(), "sky.yaml"

  merge context,
    name: "#{name}-#{context.env}-api-key"
    data:
      api: convert from: "bytes", to: "base64", await randomBytes 20

# When we create the API key, but wish to avoid overwriting anything.
upsertP = (context) ->

upsert =

create = flow [
  start
  generate
  upsertP
  upsert
]

rotate = flow [
  start
  generate
  upsert
]


export default {create, rotate}
