import {resolve} from "path"
import {confidential} from "panda-confidential"
import {yaml} from "panda-serialize"
import {read} from "panda-quill"

{randomBytes, convert} = confidential()

Generate = (env) ->
  {name} = yaml await read resolve process.cwd(), "sky.yaml"

  console.log "Key: #{name}-#{env}-api-key"
  console.log yaml
    api: convert from: "bytes", to: "base64", await randomBytes 20


export default Generate
