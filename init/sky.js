var async = require("fairmont").async;
var YAML = require("js-yaml");

// App name with its environment, context injection is roadmapped for beta-02
var name = "sky-staging";

// helper to simplify the S3 interface. Formal integration is roadmapped.
var s3 = require("./s3")(name);

// Handlers
var API = {};

API[name + "-get-description"] = async( function*(data, context, callback) {
  // Instantiate new s3 helper to target deployment "src" bucket.
  var get = require("./s3")(name + "-src").get;
  var description = YAML.safeLoad( yield( get("api.yaml")));
  return callback( null, description);
});

exports.handler = function (event, context, callback) {
  try {
    return API[context.functionName](event, context, callback);
  } catch (e) {
    return callback(e);
  }
};
