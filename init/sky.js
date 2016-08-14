let {async} = require("fairmont");
let YAML = require("js-yaml");

// App name with its environment, context injection is roadmapped for beta-02
let name = "SkyProject-staging"

// helper to simplify the S3 interface. Formal integration is roadmapped.
let {get, put} = require("./s3")(name);

let API =

  `${name}-get-description`: async (data, context, callback) =>
      let {get} = require("./s3")(`${name}-src`);
      let description = YAML.safeLoad( yield( get("description.yaml")));
      return callback( null, description);

exports.handler = (event, context, callback) =>
  API[context.functionName] event, context, callback
