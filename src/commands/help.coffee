module.exports = """

  Usage: sky [command]

  Options:

    -V, --version  output the version number
    -h, --help     output usage information


  Commands:

    build                       Compile the API, Lambdas, and resources to prepare for publishing.
    init                        Initialize a Panda Sky project.
    publish [options] [env]     Deploy API, Lambdas to AWS infrastructure
    delete [env]                Delete API, Lambdas from AWS infrastructure
    tail   [env]                Tail the logs for the given environment
      [-v, --verbose]               Output debug level logs
    render [env]                Render the CloudFormation template to STDERR
    update [env]                Update *only* the Lambda code for an environment
    list                        List all deployed envs and their endpoints
    test [env]                  Issue "npm test {env url}" after url lookup
    domain [subcommand] [env]   Manage your API's custom domain and edge cache.
      - domain publish [env]      Upserts a CloudFront distribution for your API
      - domain invalidate [env]   Invalidates your API's CloudFront edge cache
      - domain delete [env]       Deletes your API's CloudFront distribution

    mixin [name] [env] [other]  Use augemnted CLI provided by mixin

  """
