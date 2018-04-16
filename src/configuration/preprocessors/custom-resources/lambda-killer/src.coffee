# This is the Lambda Killer custom resource.  It targes all the Lambdas in the Sky deployment and deletes them.

import https from "https"
import url from "url"
import SDK from "aws-sdk"
import {lift, collect, project, select} from "fairmont"

Lambda = new SDK.Lambda()
listFunctions = lift Lambda.listFunctions
deleteFunction = lift Lambda.deleteFunction

lambda = do ->
  list = (fns=[], marker) ->
    params = {MaxItems: 100}
    params.Marker = marker if marker

    {NextMarker, Functions} = await listFunctions params
    fns = cat fns, Functions
    if NextMarker
      await list fns, NextMarker
    else
      fns

  Delete = (name) -> await deleteFunction FunctionName: name
  {list, delete:Delete}

deleteAll = (stackName) ->
  # Get names of all Lambdas that are part of this environment
  lambdas = await lambda.list()
  names = collect project "FunctionName", lambdas

  isOurs = (str) -> ///^#{s.stackName}.+///.test str
  names = collect select isOurs, names

  await Promise.all (lambda.delete name for name in names)


handler = (event, context) ->
  # For Non-Delete requests, immediately send a SUCCESS response.
  if event.RequestType != "Delete"
      sendResponse event, context, "SUCCESS"
      return

  try
    await deleteAll event.StackName
    sendResponse event, context, "SUCCESS"
  catch e
    sendResponse event, context, "FAILED", {Error: e}



# CloudFormation waits for a result JSON object to be sent to the pre-signed S3 bucket URL.
sendResponse = (event, context, responseStatus, responseData={}) ->
  responseBody = JSON.stringify
    Status: responseStatus,
    Reason: "See the details in CloudWatch Log Stream: " + context.logStreamName,
    PhysicalResourceId: context.logStreamName
    StackId: event.StackId
    RequestId: event.RequestId
    LogicalResourceId: event.LogicalResourceId
    Data: responseData

  parsedUrl = url.parse event.ResponseURL
  options =
    hostname: parsedUrl.hostname
    port: 443
    path: parsedUrl.path
    method: "PUT"
    headers:
      "content-type": "",
      "content-length": responseBody.length

  request = https.request options, -> context.done()

  request.on "error", (e) ->
    console.log "sendResponse Error:" + e
    context.done()

  request.write responseBody
  request.end()

export {handler}
