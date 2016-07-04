{async} = require "fairmont"
{resolve, join} = require "path"

module.exports = async (env, config) ->
  {lambda} = yield require("./index")(config.aws.region)
  bucket = yield require("./s3")(env, config)

  # Create and/or update an S3 bucket with lambda source files.  When the CFo
  # template is generated to deploy the lambdas, it will be directed at this bucket.
  prepareSrc = async ->
    name = "#{config.name}-#{env}-src"
    packagePath = resolve(join(process.cwd(), "deploy", "package.zip"))
    descriptionPath = resolve(join(process.cwd(), "description.yaml"))

    yield bucket.establish name
    yield bucket.putObject name, "package.zip", packagePath
    yield bucket.putObject name, "description.yaml", descriptionPath


  # Return exposed functions.
  {prepareSrc}
