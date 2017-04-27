{parse} = require "auth-header"
{async} = require "fairmont"

module.exports = (handler) ->
  handler = async handler
  # TODO: parse Accept header
  (request, context) ->
    if (header = request.headers['Authorization'])?
      {scheme, params, token} = parse header
      if token
        request.authorization = {scheme, token}
      else
        request.authorization = {scheme, params}
    handler request, context
