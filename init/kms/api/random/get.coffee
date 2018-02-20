import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws} from "panda-sky-helpers"
{KMS:{randomKey}} = aws SDK

handler = (request, context) ->
  await randomKey 16, "base64url"

export default handler
