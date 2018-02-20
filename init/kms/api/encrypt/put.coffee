import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws} from "panda-sky-helpers"
{KMS:{encrypt}} = aws SDK

handler = (request, context) ->
  {content} = request
  await encrypt "alias/#{env.fullName}", content

export default handler
