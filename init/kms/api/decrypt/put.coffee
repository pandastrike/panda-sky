import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws} from "panda-sky-helpers"
{KMS:{decrypt}} = aws SDK

handler = (request, context) ->
  {content} = request
  await decrypt content

export default handler
