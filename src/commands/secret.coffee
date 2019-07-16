import {confidential} from "panda-confidential"

{randomBytes, convert} = confidential()

Generate = ->
  console.log convert from: "bytes", to: "base64", await randomBytes 20


export default Generate
