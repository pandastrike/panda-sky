var YAML = require("js-yaml");

// Extract environment variables for this handler.
var {baseName, environment, projectID, fullName, skyBucket} = process.env;

// Access the Panda Sky helpers.
var AWS = require("aws-sdk");
var {async, s3, response} = require("panda-sky")(AWS);

// Use the S3 helper to get functions to access the App's datastore.
var {get, put, del} = s3("foobar");

// Handlers
var API = {};

API[`${fullName}-discovery-get`] = async( function*(data, context, callback) {
  // Instantiate new s3 helper to target deployment "src" bucket.
  var get = s3(`${environment}-${projectID}`).get;
  var description = YAML.safeLoad( yield( get("api.yaml")));
  return callback( null, description);
});

API[`${fullName}-greeting-get`] = async( function*(data, context, callback) {
  var message, name;
  name = data.name || "World";
  message = `<h1>Hello, ${name}!</h1>`;
  message += "<p>Seeing this page indicates a successful deployment of your test API with Panda Sky!</p>";
  return callback(null, message);
});

exports.handler = function (event, context, callback) {
  try {
    return API[context.functionName](event, context, callback);
  } catch (e) {
    return callback(e);
  }
};
