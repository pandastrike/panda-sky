{values} = require "fairmont"

module.exports = """

  Usage: sky [command]

  Options:

    -V, --version  output the version number
    -h, --help     output usage information


  Commands:

    build                       compile the API, Lambdas, and resources to prepare for publishing.
    init                        Initiallize a Panda Sky project.
    publish [options] [env]     deploy API, Lambdas to AWS infrastructure
    delete [env]                deploy API, Lambdas to AWS infrastructure
    render [env]                render the CloudFormation template to STDOUT
    update [env]                Update *only* the Lambda code for an environment
    domain [subcommand] [env]   Manage your API's custom domain and edge cache.
      - domain publish [env]      Upserts a CloudFront distribution for your API
      - domain invalidate [env]   Invalidates your API's CloudFront edge cache
      - domain delete [env]       Deletes your API's CloudFront distribution

  """
