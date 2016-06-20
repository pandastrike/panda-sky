{join} = require "path"
program = require "commander"
{call, read} = require "fairmont"

require "./index"
{run} = require "panda-9000"

call ->

  {version} = JSON.parse yield read join __dirname, "..", "package.json"

  program
    .version(version)

  program
    .command('serve')
    .description('run a Web server to test your API endpoints')
    .action(-> run "serve")

  program
    .command('build')
    .description('compile the API, Lambdas, and resources to prepare for publishing.')
    .action(-> run "build")

  program
    .command('publish [env]')
    .description('deploy API, Lambdas to AWS infrastructure')
    .action((env)-> run "publish", [env])

  program
    .command('delete [env]')
    .description('deploy API, Lambdas to AWS infrastructure')
    .action((env)-> run "delete", [env])

  # Begin execution.
  program.parse(process.argv);
