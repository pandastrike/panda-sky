{join} = require "path"
program = require "commander"
{call, read, collect, project, empty} = require "fairmont"

require "./index"
watch = require "./watch"
{run} = require "panda-9000"

call ->

  {version} = JSON.parse yield read join __dirname, "..", "package.json"

  program
    .version(version)

  program
    .command('build')
    .description('compile the API, Lambdas, and resources to prepare for publishing.')
    .action((options) -> run "build")

  program
    .command('init')
    .description('Initiallize a Panda Sky project.')
    .action(-> run "init")

  program
    .command('publish [env]')
    .description('deploy API, Lambdas to AWS infrastructure')
    .action((env)-> run "publish", [env])

  program
    .command('delete [env]')
    .description('deploy API, Lambdas to AWS infrastructure')
    .action((env)-> run "delete", [env])

  program
    .command('render [env]')
    .description('render the CloudFormation template to STDOUT')
    .action((env)-> run "render", [env])

  program
    .command('update [env]')
    .description('Update *only* the Lambda code for an environment')
    .action((env)-> run "update", [env])

  program
    .command('watch')
    .description('Watch for file changes and update *only* the Lambda code for an environment')
    .action(-> watch())

  program
    .command('*')
    .action(-> program.help())

  # Begin execution.
  program.parse process.argv
