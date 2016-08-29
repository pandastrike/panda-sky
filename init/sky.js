var async = require("fairmont").async;
var YAML = require("js-yaml");

// See wiki for more details. Configuration with context injection is roadmapped
// for Beta-02
var name = "sky";
var env = "staging";
var projectID = "{{projectID}}";
var app = name + "-" + env;

// helper to simplify the S3 interface. Formal integration is roadmapped.
var s3 = require("./s3")(app + "-" + projectID);

// Handlers
var API = {};

API[app + "-get-description"] = async( function*(data, context, callback) {
  // Instantiate new s3 helper to target deployment "src" bucket.
  var get = require("./s3")(env + "-" + projectID).get;
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
