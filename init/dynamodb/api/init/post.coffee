import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws, response} from "panda-sky-helpers"
{NotFound} = response
{DynamoDB} = aws SDK

# Instantiate new DynamoDB helper and define deployment "alpha" table.
tableName = "sky-#{env.environment}-alpha"
{tableGet, put} = DynamoDB

# Access the raw demo data.
import RAW from "./raw-data"

handler = (request, context) ->
  if !await tableGet tableName
    throw new NotFound "The Table #{tableName} cannot be found."
  else
    data = RAW DynamoDB
    await put tableName, key for key in data
    "Successfully initalized test data in DynamoDB database."

export default handler
