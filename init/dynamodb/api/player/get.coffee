import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws, response} from "panda-sky-helpers"
{NotFound} = response
{DynamoDB} = aws SDK

# Instantiate new DynamoDB helper and define deployment "alpha" table.
tableName = "sky-#{env.environment}-alpha"
{tableGet, query, to, qv, parse} = DynamoDB
encode = qv to.S

handler = (request, context) ->
  if !await tableGet tableName
    throw new NotFound "The Table #{tableName} cannot be found."
  else
    {PlayerID} = request.url.path

    {Items} = await query tableName, "PlayerID = #{encode PlayerID}"
    throw new NotFound() if Items.length == 0
    parse i for i in Items

export default handler
