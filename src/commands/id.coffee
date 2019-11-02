import {resolve} from "path"
import Base64Words from "base64-words"
import {confidential} from "panda-confidential"
import {dashed, plainText} from "panda-parchment"

{randomBytes, convert} = confidential()

Generate = (env) ->
  string = convert from: "bytes", to: "base64", await randomBytes 6
  console.log dashed plainText Base64Words.fromBase64 string


export default Generate
