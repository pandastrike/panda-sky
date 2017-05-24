{join} = require "path"
program = require "commander"
{call, read, write, collect, project, empty} = require "fairmont"

require "./index"
{run} = require "panda-9000"
{yaml} = require "panda-serialize"

{bellChar} = require "./utils"
render = require "./commands/render"
publish = require "./commands/publish"

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
    .option '-o, --output [output]', 'Path to write API config file'
    .action (env, options) ->
      call ->
        stack = yield publish env
        if options.output?
          config = url: yield stack.getApiUrl()
          yield write options.output, (yaml config)
        console.log bellChar

  program
    .command('delete [env]')
    .description('deploy API, Lambdas to AWS infrastructure')
    .action((env)-> run "delete", [env])

  program
    .command('render [env]')
    .description('render the CloudFormation template to STDOUT')
    .action (env) -> render(env)

  program
  .command('update [env]')
  .description('Update *only* the Lambda code for an environment')
  .action((env)-> run "update", [env])

  program
    .command('*')
    .action(-> program.help())

  # Begin execution.
  program.parse process.argv
