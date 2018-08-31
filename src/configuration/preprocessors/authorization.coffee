import {merge} from "fairmont"

Authorization = (description) ->

  # TODO: Make this dyanmic and sensitive to mixins.
  getAuthorization = (method) ->
    if method.signatures.request.authorization
      authorizationType: "COGNITO_USER_POOLS"
      authorizerId: JSON.stringify Ref: "MixinAPIAuthorizer"
    else
      "NONE"

  {resources} = description
  for r, resource of resources
    for httpMethod, method of resource.methods
      {authorizationType, authorizerId} = getAuthorization method
      resources[r].methods[httpMethod].authorizationType = authorizationType
      if authorizerId
        resources[r].methods[httpMethod].authorizerId = authorizerId

  description.resources = resources
  description

export default Authorization
