assert = require "assert"
amen = require "amen"
{isKind} = require "fairmont"

AWS = require "aws-sdk"
Sky = require "../.."
sky = Sky(AWS)

amen.describe "sky.method wrapper function", ({describe, test}) ->

  handler = sky.method (request) ->
    yield request

  describe "Interface", ({test}) ->

    test "returns a function", ->
      assert.equal typeof handler, "function"

    test "handler returns a promise", ->
      {constructor} = handler(headers: {})
      assert.equal constructor, Promise

  describe "Behavior", ({describe, test}) ->

    describe "authorization", ({test}) ->

      test "with custom scheme and valid params", ->

        testRequest =
          url:
            path:
              key: "somekey"
          headers:
            "Authorization": "PandaAuth key=supersecurevalue"

        {authorization} = yield handler testRequest
        assert.deepEqual authorization,
          scheme: "PandaAuth"
          params:
            key: "supersecurevalue"

