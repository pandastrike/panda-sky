assert = require "assert"
{describe} = require "amen"
{isKind} = require "fairmont"

AWS = require "aws-sdk"
Sky = require "../.."
sky = Sky(AWS)

describe "sky.method", ({describe, test}) ->

  describe "Interface", ({test}) ->

    handler = sky.method (request) ->
      yield request

    test "returns a function", ->
      assert.equal typeof handler, "function"

    test "handler returns a promise", ->
      {constructor} = handler(headers: {})
      assert.equal constructor, Promise

  describe "Behavior", ({describe, test}) ->

    describe "request.authorization", ({test}) ->

      handler = sky.method (request) ->
        yield request.authorization

      test "parses scheme and key/value params", ->

        testRequest =
          headers:
            "Authorization": "PandaAuth key=supersecurevalue"

        authorization = yield handler testRequest
        assert.deepEqual authorization,
          scheme: "PandaAuth"
          params:
            key: "supersecurevalue"

      test "parses scheme and atomic credential", ->

        testRequest =
          headers:
            "Authorization": "GrossScheme thisisjustanatomictoken"

        authorization = yield handler testRequest
        assert.deepEqual authorization,
          scheme: "GrossScheme"
          token: "thisisjustanatomictoken"

    describe "request.accept"

