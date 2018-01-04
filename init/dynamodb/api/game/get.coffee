import AWS from "aws-sdk"

# Access the Panda Sky helpers.
import sky from "panda-sky-helpers"
{env, AWS:{DynamoDB}, response:{NotFound}} = sky AWS

# Instantiate new DynamoDB helper and define deployment "alpha" table.
tableName = "sky-#{env.environment}-alpha"
{tableGet, query, to, qv, parse} = DynamoDB
encode = qv to.S

# I borrowed these helpers from Fairmont-Helpers:Strings
plainText = (string) ->
  string
    .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
    .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )
    .replace( /\W+/g, " " )

titleCase = (string) ->
  string
  .toLowerCase()
  .replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())

handler = (request, context) ->
  if !await tableGet tableName
    throw new NotFound "The Table #{tableName} cannot be found."
  else
    title = titleCase plainText request.url.path.GameTitle

    name = "#{tableName}:GameTitleIndex"
    {Items} = await query name, "GameTitle = #{encode title}"
    throw new NotFound() if Items.length == 0
    parse i for i in Items

export default handler
