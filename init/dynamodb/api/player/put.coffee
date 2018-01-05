import SDK from "aws-sdk"

# Access the Panda Sky helpers.
import {env, aws, response} from "panda-sky-helpers"
{NotFound} = response
{DynamoDB} = aws SDK

# Instantiate new DynamoDB helper and define deployment "alpha" table.
tableName = "sky-#{env.environment}-alpha"
{tableGet, query, put, to, qv, parse, merge} = DynamoDB
encode = qv to.S

handler = (request, context) ->
  if !await tableGet tableName
    throw new NotFound "The Table #{tableName} cannot be found."
  else
    {PlayerID} = request.url.path
    {GameTitle, Win, Score} = request.content

    # Check to see if the record already exists in the table.
    {Items} = await query tableName, "PlayerID = #{encode PlayerID} AND GameTitle = #{encode GameTitle}"

    if Items.length == 0
      Wins = Losses = 0
      TopScore = Score || 0
    else
      r = parse Items[0]
      {Wins, Losses, TopScore} = r
      TopScore = Score if Score > TopScore

    if Win then Wins++ else Losses++
    key = merge to.S({PlayerID, GameTitle}), to.N({Wins, Losses, TopScore})
    await put tableName, key
    "Successfully added to Player #{PlayerID}"

export default handler
